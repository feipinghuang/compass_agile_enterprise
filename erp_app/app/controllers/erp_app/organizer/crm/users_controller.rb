module ErpApp
  module Organizer
    module Crm
      class UsersController < ErpApp::Organizer::BaseController

        def index
          party_roles = params[:party_roles]
          to_role = params[:to_role]
          to_party_id = params[:to_party_id]
          offset = params[:start] || 0
          limit = params[:limit] || 25
          included_party_to_relationships = ActiveSupport::JSON.decode params[:included_party_to_relationships]
          query_filter = params[:query_filter] || nil

          # determine sorting
          sort_hash = params[:sort].present? ? ActiveSupport::JSON.decode(params[:sort]).first : {}

          #
          # Convert sort parameters that are mapped Extjs fields
          #
          if sort_hash['property'] == 'createdAt'
            sort_hash['property'] = 'created_at'
          elsif sort_hash['property'] == 'updatedAt'
            sort_hash['property'] = 'updated_at'
          elsif sort_hash['property'] == 'status'
            sort_hash['property'] = 'activation_state'
          elsif sort_hash['property'] == 'lastLoginAt'
            sort_hash['property'] = 'last_login_at'
          elsif sort_hash['property'] == 'lastLogoutAt'
            sort_hash['property'] = 'last_logout_at'
          elsif sort_hash['property'] == 'lastActivityAt'
            sort_hash['property'] = 'last_activity_at'
          end

          order_by = sort_hash['property'] || 'created_at'
          direction = sort_hash['direction'] || 'desc'

          user_table = User.arel_table

          if party_roles.present?
            statement = User.joins(:party => :party_roles).where(:party_roles => {:role_type_id => RoleType.where(:internal_identifier => party_roles).all})
          end

          unless to_role.blank?
            to_role_type = RoleType.iid(to_role)

            if to_party_id.blank?
              to_party = current_user.party
              to_party_rln = to_party.from_relationships.where('role_type_id_to = ?', to_role_type).first

              unless to_party_rln.nil?
                statement = statement.joins("join party_relationships on party_relationships.party_id_from = parties.id")
                .where('party_relationships.party_id_to = ?', to_party_rln.party_id_to)
                .where('party_relationships.role_type_id_to' => to_role_type)
              end
            else
              to_party = Party.find(to_party_id)

              statement = statement.joins("join party_relationships on party_relationships.party_id_from = parties.id")
              .where('party_relationships.party_id_to = ?', to_party.id)
              .where('party_relationships.role_type_id_to' => to_role_type)
            end
          end

          if query_filter
            statement = statement.where(user_table[:username].matches("%#{query_filter}%")
                                        .or(user_table[:email].matches("%#{query_filter}%")))
          end

          total = statement.uniq.count
          users = statement.uniq.order("#{order_by} #{direction}").limit(limit).offset(offset).all

          data = {
              :success => true,
              :users => users.collect do |user|
                user_data = user.to_hash(:only =>
                                             [:id, :username,
                                              :email,
                                              :last_login_at,
                                              :last_logout_at,
                                              :last_activity_at,
                                              :created_at,
                                              :updated_at,
                                              :activation_state],
                                         :party_description => (user.party.description))

                # add relationships
                included_party_to_relationships.each do |included_party_to_relationship|
                  included_party_to_relationship.symbolize_keys!

                  relationship = user.party.relationships.where('relationship_type_id = ?', RelationshipType.find_by_internal_identifier(included_party_to_relationship[:relationshipType])).first
                  if relationship
                    user_data[included_party_to_relationship[:toRoleType]] = relationship.to_party.description
                  end
                end

                if user.party.business_party.class == Individual
                  user_data[:first_name] = user.party.business_party.current_first_name
                  user_data[:last_name] = user.party.business_party.current_last_name
                end

                user_data
              end,
              :total => total
          }

          render :json => data
        end

        def show
          result = {:success => true}

          user = User.where('id = ?', params[:id]).first

          if user
            individual = user.party.business_party

            result[:user] = user.to_hash(:only =>
                                             [:id,
                                              :username,
                                              :email,
                                              :last_login_at,
                                              :created_at,
                                              :updated_at,
                                              :activation_state],
                                         :first_name => individual.current_first_name,
                                         :last_name => individual.current_last_name)
          end

          render :json => result
        end

        def create
          result = {}

          user_data = params[:data].present? ? params[:data] : params
          party_id = params[:party_id] || user_data[:party_id]

          party = party_id.blank? ? nil : Party.find(party_id)

          begin
            ActiveRecord::Base.transaction do
              user = User.new(
                  :email => user_data['email'].strip,
                  :username => user_data['username'].strip,
              )

              if user_data[:password].present? && user_data[:password_confirmation].present?
                user.password = user_data[:password].strip
                user.password_confirmation = user_data[:password_confirmation].strip
                user.add_instance_attribute(:temp_password, user_data[:password])
              else
                temp_password = 'AB' + SecureRandom.uuid[0..5] + 'CD'
                user.password = temp_password
                user.password_confirmation = temp_password
                user.add_instance_attribute(:temp_password, temp_password)
              end

              #set this to tell activation where to redirect_to for login and temp password
              user.add_instance_attribute(:login_url, '/erp_app/login')

              # if a party was passed create this user with the party if not then create a individual now
              if party
                user.party = party
              else
                individual = Individual.create(current_first_name: params[:first_name].strip,
                                               current_last_name: params[:last_name].strip)

                user.party = individual.party

                # add a party roles if passed
                if params[:party_roles].present?
                  params[:party_roles].split(',').each do |party_role|
                    PartyRole.create(party: individual.party, role_type: RoleType.iid(party_role))
                  end
                end
              end

              if params[:skip_activation_email].present? and params[:skip_activation_email] === 'true'
                user.skip_activation_email = true
              end

              # add security roles if present
              if params[:security_roles].present?
                params[:security_roles].split(',').each do |security_role|
                  user.party.add_role(security_role)
                end
              end

              if user.save
                if params[:skip_activation_email].present? and params[:skip_activation_email] === 'true'
                  if user_data[:activation_state].present? and user_data[:activation_state] != 'pending'
                    user.activation_state = user_data[:activation_state].strip
                    user.save!
                  end
                end

                result = {:success => user.save, :users => user.to_hash(:only =>
                                                                            [:id, :username,
                                                                             :email,
                                                                             :last_login_at,
                                                                             :created_at,
                                                                             :updated_at,
                                                                             :activation_state])}
              else
                result = {:success => false, :message => user.errors.full_messages.to_sentence}
              end
            end
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            result = {:success => false, :message => "Error adding user."}
          end

          render :json => result
        end

        def update
          user_data = params[:data].present? ? params[:data] : params

          user = User.find(params[:id])

          user.username = user_data[:username].strip
          user.email = user_data[:email].strip

          # update first name and last of individual if passed
          if params[:first_name].present? and params[:last_name].present?
            individual = user.party.business_party

            individual.current_first_name = params[:first_name].strip
            individual.current_last_name = params[:last_name].strip

            individual.save
          end

          if user_data[:activation_state].present?
            user.activation_state = user_data[:activation_state].strip
          end

          if user_data[:password].present? && user_data[:password_confirmation].present?
            user.password = user_data[:password].strip
            user.password_confirmation = user_data[:password_confirmation].strip
          end

          if user.save
            result = {:success => user.save, :users => user.to_hash(:only =>
                                                                        [:id, :username,
                                                                         :email,
                                                                         :last_login_at,
                                                                         :created_at,
                                                                         :updated_at,
                                                                         :activation_state])}
          else
            result = {:success => false, :message => user.errors.full_messages.to_sentence}
          end

          render :json => result
        end

        def destroy
          user = User.find(params[:id])

          render :json => {:success => user.destroy}
        end

      end #BaseController
    end #Crm
  end #Organizer
end #ErpApp