module Api
  module V1
    class UsersController < BaseController

      def index
        username = params[:username]
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'username'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0

        # scope users by dba_organization and any of its children dba_orgs
        dba_organization = current_user.party.dba_organization
        dba_org_ids = dba_organization.child_dba_organizations.collect(&:id)
        dba_org_ids.push(dba_organization.id)
        dba_org_ids.uniq!

        users = User.joins(:party).joins("inner join party_relationships as dba_reln on
                          (dba_reln.party_id_from = parties.id
                          and
                          dba_reln.party_id_to in (#{dba_org_ids.join(',')})
                          and
                          dba_reln.role_type_id_to = #{RoleType.iid('dba_org').id}
                          )")

        if username.blank?
          total_count = users.uniq.count
          users = users.order("#{sort} #{dir}").offset(start).limit(limit)
        else
          users = users.where('username like ? or email like ?', "%#{username}%", "%#{username}%")
          total_count = users.uniq.count
          users = users.order("#{sort} #{dir}").offset(start).limit(limit)
        end

        render :json => {total_count: total_count, users: users.uniq.collect(&:to_data_hash)}
      end

      def create
        response = {}
        begin
          ActiveRecord::Base.connection.transaction do
            current_user.with_capability(:create, 'User') do

              user = User.new(
                  :email => params[:email],
                  :username => params[:username],
                  :password => params[:password],
                  :password_confirmation => params[:password_confirmation]
              )

              # set this to tell activation where to redirect_to for login and temp password
              login_url = params[:login_url] || '/erp_app/login'

              #set this to tell activation where to redirect_to for login and temp password
              user.add_instance_attribute(:login_url, login_url)
              user.add_instance_attribute(:temp_password, params[:password])

              if user.save
                individual = Individual.create(:gender => params[:gender],
                                               :current_first_name => params[:first_name],
                                               :current_last_name => params[:last_name])
                user.party = individual.party
                user.save

                # add employee role to party
                party = individual.party
                party.add_role_type(RoleType.find_or_create('employee', 'Employee'))

                # associate the new party to the dba_organization of the user creating this user
                relationship_type = RelationshipType.find_or_create(RoleType.find_or_create('dba_org', 'Doing Business As Organization'),
                                                                    RoleType.find_or_create('employee', 'Employee'))
                party.create_relationship(relationship_type.description,
                                          current_user.party.dba_organization.id,
                                          relationship_type)

                response = {:success => true}
              else
                message = "<ul>"
                user.errors.collect do |e, m|
                  message << "<li>#{e} #{m}</li>"
                end
                message << "</ul>"
                response = {:success => false, :message => message, :user => user.to_data_hash}
              end

              render :json => response
            end
          end
        rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
          render :json => {:success => false, :message => ex.message, :user => null}
        end
      end

      def reset_password
        begin
          login_url = params[:login_url].blank? ? ErpTechSvcs::Config.login_url : params[:login_url]
          login = params[:id].strip
          if user = (User.where('username = ? or email = ?', login, login)).first

            # generate new password with only letters
            charset = %w{ A C D E F G H J K M N P Q R T V W X Y Z }
            new_password = (0...8).map { charset.to_a[rand(charset.size)] }.join

            user.password_confirmation = new_password
            if user.change_password!(new_password)
              user.add_instance_attribute(:login_url, login_url)
              user.add_instance_attribute(:domain, params[:domain])
              user.deliver_reset_password_instructions!
              message = "Password has been reset.  An email has been sent with further instructions to #{user.email}."
              success = true
            else
              message = "Error re-setting password."
              success = false
            end
          else
            message = "Invalid user name or email address."
            success = false
          end
          render :json => {:success => success, :message => message}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {:success => false, :message => 'Error sending email.'}
        end
      end

      def destroy
        user = User.find(params[:id])

        # get the party as it will also destroy the user
        party = user.party
        party.destroy

        render :json => {:success => true}
      end

    end # UsersController
  end # V1
end # Api