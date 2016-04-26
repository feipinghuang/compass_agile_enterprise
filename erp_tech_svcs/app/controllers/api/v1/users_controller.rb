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

        # TODO update for more advance searching
        if params[:query_filter].present?
          username = params[:query_filter].strip
        end

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

              if params[:auto_activate] == 'yes'
                user.skip_activation_email = true
              end

              user.save!
              if params[:auto_activate] == 'yes'
                user.activate!
              end

              individual = Individual.create(:gender => params[:gender],
                                             :current_first_name => params[:first_name],
                                             :current_last_name => params[:last_name])
              user.party = individual.party
              user.save

              user.party.created_by_party = current_user.party
              user.party.save!

              # add employee role to party
              party = individual.party
              party.add_role_type(RoleType.find_or_create('employee', 'Employee'))

              # associate the new party to the dba_organization of the user creating this user
              relationship_type = RelationshipType.find_or_create(RoleType.find_or_create('dba_org', 'Doing Business As Organization'),
                                                                  RoleType.find_or_create('employee', 'Employee'))
              party.create_relationship(relationship_type.description,
                                        current_user.party.dba_organization.id,
                                        relationship_type)

              render :json => {:success => true}
            end
          end
        rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
          render :json => {:success => false, :message => ex.message, :user => nil}
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          message = "<ul>"
          invalid.record.errors.collect do |e, m|
            message << "<li>#{e} #{m}</li>"
          end
          message << "</ul>"

          render :json => {:success => false, :message => message, :user => nil}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {:success => false, :message => 'Error creating user', :user => nil}
        end
      end

      def update
        begin
          ActiveRecord::Base.transaction do

            user = current_user
            party = user.party
            business_party = party.business_party

            # update business party information
            if params[:first_name].present?
              business_party.first_name = params[:first_name].strip
            end

            if params[:last_name].present?
              business_party.last_name = params[:last_name].strip
            end

            # update password if passed
            if params[:password].present?
              user.password = params[:password].strip
              user.password_confirmation = params[:password].strip
            end

            user.party.updated_by_party = current_user.party
            user.party.save!

            user.email = params[:email].strip

            user.save!

            render :json => {:success => true, :message => 'User updated', :user => user.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors.full_messages, :user => nil}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {:success => false, :message => 'Error updating user', :user => nil}
        end

      end

      def reset_password
        begin
          user = User.find(params[:id])

          user.add_instance_attribute(:reset_password_url, (params[:reset_password_url] || '/erp_app/reset_password'))
          user.add_instance_attribute(:domain, params[:domain])
          user.deliver_reset_password_instructions!
          message = "Password has been reset. An email has been sent with further instructions to #{user.email}."
          success = true
          render :json => {:success => success, :message => message}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {:success => false, :message => 'Could not reset password'}
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
