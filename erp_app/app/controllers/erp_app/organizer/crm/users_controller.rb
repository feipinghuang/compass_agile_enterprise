module ErpApp
  module Organizer
    module Crm
      class UsersController < ErpApp::Organizer::BaseController

        def index
          render :json => if request.get?
                            get_users
                          elsif request.post?
                            create_user
                          elsif request.put?
                            update_user
                          elsif request.delete?
                            delete_user
                          end
        end

        def user_for_party
          result = {:success => true}

          party = Party.find(params[:party_id])

          user = party.user

          if user
            result[:user] = user.to_hash(:only =>
                                             [:id, :username,
                                              :email,
                                              :last_login_at,
                                              :created_at,
                                              :updated_at,
                                              :activation_state])
          end

          render :json => result
        end

        protected

        def get_users
          party_role = params[:party_role]
          to_role = params[:to_role]
          to_party_id = params[:to_party_id]
          offset = params[:offset] || 0
          limit = params[:limit] || 25
          query_filter = params[:query_filter] || nil

          user_table = User.arel_table

          statement = User.joins(:party => :party_roles).where(:party_roles => {:role_type_id => RoleType.iid(party_role).id})

          unless to_role.blank?
            to_role_type = RoleType.iid(to_role)

            if to_party_id.blank?
              to_party = current_user.party
              to_party_rln = to_party.from_relationships.where('role_type_id_to = ?', to_role_type).first

              statement = statement.joins("join party_relationships on party_relationships.party_id_from = parties.id")
              .where('party_relationships.party_id_to = ?', to_party_rln.party_id_to)
              .where('party_relationships.role_type_id_to' => to_role_type)
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
          users = statement.uniq.limit(limit).offset(offset).all

          {:success => true,
           :users => users.collect do |user|
             user_data = user.to_hash(:only =>
                                          [:id, :username,
                                           :email,
                                           :last_login_at,
                                           :created_at,
                                           :updated_at,
                                           :activation_state],
                                      :party_description => (user.party.description))

             if user.party.business_party.class == Individual
               user_data[:first_name] = user.party.business_party.current_first_name
               user_data[:last_name] = user.party.business_party.current_last_name
             end

             user_data
           end,
           :total => total}
        end

        def create_user
          result = {}

          user_data = params[:data].present? ? params[:data] : params
          party_id = params[:party_id] || user_data[:party_id]

          party = Party.find(party_id)

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

              user.party = party

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
            end
          rescue Exception => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            result = {:success => false, :message => "Error adding user."}
          end

          result
        end

        def update_user
          user_data = params[:data].present? ? params[:data] : params

          user = User.find(params[:id])

          user.username = user_data[:username].strip
          user.email = user_data[:email].strip

          if user_data[:activation_state].present? && user_data[:activation_state] != 'pending'
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

          result
        end

        def delete_user
          user = User.find(params[:id])

          {:success => user.destroy}
        end

      end #BaseController
    end #Crm
  end #Organizer
end #ErpApp