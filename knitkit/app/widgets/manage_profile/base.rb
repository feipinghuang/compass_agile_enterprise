module Widgets
  module ManageProfile
    class Base < ErpApp::Widgets::Base

      def index
        @user = User.find(current_user)
        @individual = @user.party.business_party
        @email_addresses = @user.party.find_all_contacts_by_contact_mechanism(EmailAddress)
        @phone_numbers = @user.party.find_all_contacts_by_contact_mechanism(PhoneNumber)
        @postal_addresses = @user.party.find_all_contacts_by_contact_mechanism(PostalAddress)

        contact_purposes = ContactPurpose.all
        @purpose_hash={}
        contact_purposes.each do |p|
          @purpose_hash[p.description]=p.internal_identifier
        end

        countries= GeoCountry.all
        @countries_id=[]
        @countries_id << ["Country", "default"]
        countries.each do |c|
          @countries_id << [c.name, c.id]
        end

        states= GeoZone.all
        @states_id=[]
        @states_id << ["State", "default"]
        states.each do |s|
          @states_id << [s.zone_name, s.id]
        end

        render
      end

      def update_user_information
        #### Get appropriate models ####

        @user = User.find(current_user)
        @individual = @user.party.business_party

        @individual.current_first_name = params[:first_name]
        @individual.current_last_name = params[:last_name]
        @individual.current_middle_name = params[:middle_name]
        @user.email = params[:email]

        #### check validation then save and render message ####
        if @user.changed? || @individual.changed?
          if @user.valid? && @individual.valid?
            @user.save
            @individual.save
            @message = "User Information Updated"

            render :update => {:id => "#{@uuid}_result", :view => :success}
          else
            @message_cls = 'sexyerror'
            @message = "Error Updating User Information"
            render :update => {:id => "#{@uuid}_result", :view => :error}
          end
        else
          @message = "User Information Updated"
          render :update => {:id => "#{@uuid}_result", :view => :success}
        end

      end

      def update_password
        ActiveRecord::Base.connection.transaction do
          begin
            if @user = User.authenticate(current_user.username, params[:old_password])

              if !params[:new_password].blank? && !params[:password_confirmation].blank? && params[:new_password] == params[:password_confirmation]

                @user.password_confirmation= params[:password_confirmation]

                if @user.change_password!(params[:new_password])
                  @message = "Password Updated"

                  render :update => {:id => "#{@uuid}_result", :view => :success}
                else
                  @message = "Error Updating Password"

                  #### validation failed ####
                  render :update => {:id => "#{@uuid}_result", :view => :error}
                end

              else
                #### password and password confirmation cant be blank or unequal ####
                @message = "Password Confirmation Must Match Password"

                render :update => {:id => "#{@uuid}_result", :view => :error}
              end
            else
              #### old password wrong ####
              @message = "Invalid Old Password"

              render :update => {:id => "#{@uuid}_result", :view => :error}
            end
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            @message = 'Could not update password'

            render :update => {:id => "#{@uuid}_result", :view => :error}
          end
        end

      end

      def add_email_address
        ActiveRecord::Base.connection.transaction do
          begin
            email_address = params[:email_address].strip
            contact_purpose = params[:contact_purpose]

            email = current_user.party.add_contact(EmailAddress,
                                                   {email_address: email_address},
                                                   ContactPurpose.find_by_internal_identifier(contact_purpose))

            {:json => {success: true, message: 'Email added', email: email.to_hash(:only => [:id, :email_address],
                                                                                   :contact_purpose => ContactPurpose.find_by_internal_identifier(contact_purpose).description)}}
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            {:json => {success: false, message: 'Could not add email'}}
          end
        end
      end

      def remove_email_address
        ActiveRecord::Base.connection.transaction do
          begin
            email_address_id = params[:email_address_id].strip

            EmailAddress.find(email_address_id).destroy

            {:json => {success: true, message: 'Email removed'}}
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            {:json => {success: false, message: 'Could not remove email'}}
          end
        end
      end

      def add_phone_number
        ActiveRecord::Base.connection.transaction do
          begin
            phone_number = params[:phone_number].strip
            contact_purpose = params[:contact_purpose]

            phone_number = current_user.party.add_contact(PhoneNumber,
                                                          {phone_number: phone_number},
                                                          ContactPurpose.find_by_internal_identifier(contact_purpose))

            {:json => {success: true, message: 'Phone number added', phone: phone_number.to_hash(:only => [:id, :phone_number],
                                                                                                 :contact_purpose => ContactPurpose.find_by_internal_identifier(contact_purpose).description)}}
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            {:json => {success: false, message: 'Could not add phone number'}}
          end
        end
      end

      def remove_phone_number
        ActiveRecord::Base.connection.transaction do
          begin
            phone_number_id = params[:phone_number_id].strip

            PhoneNumber.find(phone_number_id).destroy

            {:json => {success: true, message: 'Phone number removed'}}
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            {:json => {success: false, message: 'Could not remove phone number'}}
          end
        end
      end

      def add_address
        ActiveRecord::Base.connection.transaction do
          begin
            address_line_1 = params[:address_line_1].strip
            address_line_2 = params[:address_line_2].strip
            city = params[:city].strip
            geo_zone_id = params[:state].strip
            postal_code = params[:postal_code].strip
            contact_purpose = params[:contact_purpose]

            postal_address = current_user.party.add_contact(PostalAddress,
                                                            {
                                                                address_line_1: address_line_1,
                                                                address_line_2: address_line_2,
                                                                city: city,
                                                                geo_zone_id: geo_zone_id,
                                                                state: GeoZone.find(geo_zone_id).zone_name,
                                                                zip: postal_code,
                                                            },
                                                            ContactPurpose.find_by_internal_identifier(contact_purpose))

            {:json => {success: true,
                       message: 'Address added',
                       address: postal_address.to_hash(:only => [:id, :address_line_1, :address_line_2,
                                                                 :city, :state, :zip],
                                                       :contact_purpose => ContactPurpose.find_by_internal_identifier(contact_purpose).description)}}
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            {:json => {success: false, message: 'Could not add address'}}
          end
        end
      end

      def remove_address
        ActiveRecord::Base.connection.transaction do
          begin
            address_id = params[:address_id].strip

            PostalAddress.find(address_id).destroy

            {:json => {success: true, message: 'address removed'}}
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            {:json => {success: false, message: 'Could not remove address'}}
          end
        end
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Manage Profile"
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
      end # Class Methods

    end # Base
  end # ManageProfile
end # Widgets

