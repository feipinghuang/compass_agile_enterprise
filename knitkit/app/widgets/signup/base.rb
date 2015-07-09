module Widgets
  module Signup
    class Base < ErpApp::Widgets::Base

      def index
        @login_url = params[:login_url]
        @user = User.new

        render
      end

      def new
        @website = Website.find_by_host(request.host_with_port)
        @configuration = @website.configurations.first
        password_config_option = @configuration.get_item(ConfigurationItemType.find_by_internal_identifier('password_strength_regex')).options.first
        primary_host = @configuration.get_item(ConfigurationItemType.find_by_internal_identifier('primary_host')).options.first
        @email = params[:email]

        begin
          ActiveRecord::Base.transaction do
            @user = User.new(
                :email => @email,
                :username => params[:username],
                :password => params[:password],
                :password_confirmation => params[:password_confirmation]
            )
            @user.password_validator = {:regex => password_config_option.value, :error_message => password_config_option.comment}
            #set this to tell activation where to redirect_to for login and temp password
            @user.add_instance_attribute(:login_url, params[:login_url])
            @user.add_instance_attribute(:domain, primary_host.value)

            if @user.save

              # check if there is already a party with that email if there is tie the party to the user
              party = Party.find_by_email(@email, 'billing')
              if party
                @user.party = party
              else
                individual = Individual.create(:current_first_name => params[:first_name], :current_last_name => params[:last_name])
                @user.party = individual.party
              end

              # add website security role to user
              @user.add_role(@website.role)

              # create website_party_role for this user as a member of the site
              WebsitePartyRole.create(party: @user.party, website: @website, role_type: RoleType.find_by_ancestor_iids(['website', 'member']))

              @user.save
              party = @user.party

              # add party roles to party if present
              unless params[:party_roles].blank?
                params[:party_roles].split(',').each do |role_type|
                  party.add_role_type(role_type)
                end

                party.save
              end

              # associate the new party to the dba_organization of the current website
              relationship_type = RelationshipType.find_or_create(RoleType.iid('dba_org'), RoleType.iid('customer'))
              @dba_party = @website.website_party_roles.where('role_type_id' => RoleType.iid('dba_org')).first.party
              party.create_relationship(relationship_type.description,
                                        @dba_party.id,
                                        relationship_type)
              party.save

              after_registration

              render :update => {:id => "#{@uuid}_result", :view => :success}
            else
              render :update => {:id => "#{@uuid}_result", :view => :error}
            end
          end
        rescue => ex
          logger.error ex.message
          logger.error ex.backtrace
          render :update => {:id => "#{@uuid}_result", :view => :error}
        end
      end

      def after_registration
        #override in your code to do special registration logic
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Sign Up"
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end

        def base_layout
          begin
            file = File.join(File.dirname(__FILE__), "/views/layouts/base.html.erb")
            IO.read(file)
          rescue
            return nil
          end
        end

      end

    end # Base
  end # Signup
end # Widgets

