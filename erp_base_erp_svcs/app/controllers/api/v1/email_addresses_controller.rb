module API
  module V1
    class EmailAddressesController < BaseController

=begin
 @api {get} /api/v1/email_addresses
 @apiVersion 1.0.0
 @apiName GetEmailAddresses
 @apiGroup EmailAddress
 @apiDescription Get Email Addresses

 @apiParam (query) {String} [contact_purposes] Comma delimitted string of ContactPurpose internal identifiers to filter by.
 @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
 @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25

 @apiSuccess (200) {Object} get_email_addresses_response Response.
 @apiSuccess (200) {Boolean} get_email_addresses_response.success True if the request was successful.
 @apiSuccess (200) {Number} get_email_addresses_response.total_count Total count of records based on any filters applied
 @apiSuccess (200) {Object[]} get_email_addresses_response.email_addresses
 @apiSuccess (200) {Number} get_email_addresses_response.email_addresses.id Id.
 @apiSuccess (200) {String} get_email_addresses_response.email_addresses.description Description.
 @apiSuccess (200) {String} get_email_addresses_response.email_addresses.email_address Email Address.
=end

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'

        contact_purposes = []
        if params[:contact_purposes].present?
          contact_purposes = ContactPurpose.where(internal_identifier: params[:contact_purposes].split(',')).all
        end

        email_addresses = EmailAddress

        if params[:party_id]
          email_addresses = email_addresses.for_party(Party.find(params[:party_id]), contact_purposes)
        else
          unless contact_purposes.empty?
            email_addresses = email_addresses.joins(contact: :contact_purposes).where(contact_purposes: {id: contact_purposes})
          end
        end

        if params[:query]
          email_addresses = email_addresses.where(EmailAddress.arel_table[:description].matches("%#{params[:query]}%"))
        end

        total_count = email_addresses.count

        if params[:limit].present?
          email_addresses = email_addresses.limit(params[:limit])
        end

        if params[:start].present?
          email_addresses = email_addresses.offset(params[:start])
        end

        email_addresses = email_addresses.uniq.order(sanitize_sql_array(['%s %s', sort, dir]))

        render :json => {success: true, total_count: total_count, email_addresses: email_addresses.all.collect(&:to_data_hash)}
      end

=begin
 @api {get} /api/v1/email_addresses/:id 
 @apiVersion 1.0.0
 @apiName GetEmailAddress
 @apiGroup EmailAddress
 @apiDescription Get Email Address

 @apiParam (path) {Number} id Id of Email Address to get
 
 @apiSuccess (200) {Object} get_email_address_response Response.
 @apiSuccess (200) {Boolean} get_email_address_response.success True if the request was successful.
 @apiSuccess (200) {Object} get_email_address_response.email_address
 @apiSuccess (200) {Number} get_email_address_response.email_address.id Id.
 @apiSuccess (200) {String} get_email_address_response.email_address.description Description.
 @apiSuccess (200) {String} get_email_address_response.email_address.email_address Email Address.
=end

      def show
        begin
          render json: {success: true, email_address: EmailAddress.find(params[:id]).to_data_hash}
        rescue ActiveRecord::RecordNotFound
          render json: {success: false, error: 'Record not found'}, status: 404
        end
      end

=begin
  @api {post} /api/v1/email_addresses
  @apiVersion 1.0.0
  @apiName CreateEmailAddress
  @apiGroup EmailAddress
  @apiDescription Create Email Address

  @apiParam (body) {String} [contact_purposes] Comma delimitted string of ContactPurpose internal identifiers to filter by.
  @apiParam (body) {String} email_address Email Address.
  @apiParam (body) {String} description Description of Email Address.
  
  @apiSuccess (200) {Object} create_email_address_response Response.
  @apiSuccess (200) {Boolean} create_email_address_response.success True if the request was successful.
  @apiSuccess (200) {Object} create_email_address_response.email_address
  @apiSuccess (200) {Number} create_email_address_response.email_address.id Id.
  @apiSuccess (200) {String} create_email_address_response.email_address.description Description.
  @apiSuccess (200) {String} create_email_address_response.email_address.email_address Email Address.
=end

      def create
        begin
          ActiveRecord::Base.transaction do
            email_address = EmailAddress.create(email_address: params[:email_address],
                                                description: params[:description])

            if params[:party_id].present?
              email_address.contact.contact_record = Party.find(params[:party_id])
              email_address.contact.save!
            end

            if params[:contact_purposes].present?
              params[:contact_purposes].split(',').each do |contact_purpose_iid|
                email_address.contact.contact_purposes << ContactPurpose.iid(contact_purpose_iid)
              end
            end

            if params[:is_primary].present?
              email_address.contact.is_primary = (params[:is_primary].to_bool === true)
            end

            email_address.created_by_party = current_user.party
            email_address.contact.save!
            email_address.save!

            render json: {success: true, email_address: email_address.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render json: {success: false, message: invalid.record.errors.full_messages.join(', ')}, status: 500
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: ex.message}, status: 500
        end
      end

=begin
  @api {put} /api/v1/email_addresses/:id Update Email Address
  @apiVersion 1.0.0
  @apiName UpdateEmailAddress
  @apiGroup EmailAddress
  @apiDescription Update Email Address
  
  @apiParam (path) {Number} id Id of Email Address to update.
  
  @apiParam (body) {String} [contact_purposes] Comma delimitted string of ContactPurpose internal identifiers to filter by.
  @apiParam (body) {String} [email_address] Email Address.
  @apiParam (body) {String} [description] Description of Email Address.

  @apiSuccess (200) {Object} update_email_address_response Response.
  @apiSuccess (200) {Boolean} update_email_address_response.success True if the request was successful.
  @apiSuccess (200) {Object} update_email_address_response.email_address
  @apiSuccess (200) {Number} update_email_address_response.email_address.id Id.
  @apiSuccess (200) {String} update_email_address_response.email_address.description Description.
  @apiSuccess (200) {String} update_email_address_response.email_address.email_address Email Address.
=end

      def update
        begin
          ActiveRecord::Base.transaction do
            email_address = EmailAddress.find(params[:id])

            if params[:description].present?
              email_address.description = params[:description]
            end

            if params[:email_address].present?
              email_address.email_address = params[:email_address]
            end

            if params[:contact_purposes].present?
              email_address.contact.contact_purposes.delete_all

              params[:contact_purposes].split(',').each do |contact_purpose_iid|
                email_address.contact.contact_purposes << ContactPurpose.iid(contact_purpose_iid)
              end
            end

            if params[:is_primary].present?
              email_address.contact.is_primary = (params[:is_primary].to_bool === true)
            end

            email_address.contact.save!
            email_address.save!

            email_address.updated_by_party = current_user.party
            email_address.save!

            render :json => {success: true, email_address: email_address.to_data_hash}
          end
        rescue ActiveRecord::RecordNotFound
          render json: {success: false, error: 'Record not found'}, status: 404

        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}, status: 500
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: ex.message}, status: 500
        end
      end

=begin
  @api {delete} /api/v1/email_addresses/:id Delete Email Address
  @apiVersion 1.0.0
  @apiName DeleteEmailAddress
  @apiGroup EmailAddress
  @apiDescription Delete Email Address  

  @apiParam (path) {Number} id Id of Email Address to get.
  
  @apiSuccess (200) {Object} delete_email_address_response Response.
  @apiSuccess (200) {Boolean} delete_email_address_response.success True if the request was successful.
=end

      def destroy
        begin
          email_address = EmailAddress.find(params[:id])

          render json: {success: email_address.destroy}
        rescue ActiveRecord::RecordNotFound
          render json: {success: false, error: 'Record not found'}, status: 404
        end
      end

    end # EmailAddressesController
  end # V1
end # API
