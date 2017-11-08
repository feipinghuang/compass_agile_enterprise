module API
  module V1
    class PhoneNumbersController < BaseController

=begin

 @api {get} /api/v1/phone_numbers Index
 @apiVersion 1.0.0
 @apiName GetPhoneNumbers
 @apiGroup PhoneNumber

 @apiParam {String} [contact_purposes] Comma delimitted string of ContactPurpose internal identifiers to filter by
 
 @apiSuccess (200) {Object} get_phone_numbers_response Response
 @apiSuccess (200) (query) {Boolean} get_phone_numbers_response.success True if the request was successful
 @apiSuccess (200) (query) {Number} get_phone_numbers_response.total_count Total count of records based on any filters applied
 @apiSuccess (200) (query) {Object[]} get_phone_numbers_response.phone_numbers List of PhoneNumber records
 @apiSuccess (200) (query) {Number} get_phone_numbers_response.phone_numbers.id Id of PhoneNumber

=end

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'

        contact_purposes = []
        if params[:contact_purposes].present?
          contact_purposes = ContactPurpose.where(internal_identifier: params[:contact_purposes].split(',')).all
        end

        phone_numbers = PhoneNumber

        if params[:party_id]
          phone_numbers = phone_numbers.for_party(Party.find(params[:party_id]), contact_purposes)
        else
          unless contact_purposes.empty?
            phone_numbers = phone_numbers.where(contact_purposes: {id: contact_purposes})
          end
        end

        if params[:query]
          phone_numbers = phone_numbers.where(PhoneNumber.arel_table[:description].matches("%#{params[:query]}%"))
        end

        total_count = phone_numbers.count

        if params[:limit].present?
          phone_numbers = phone_numbers.limit(params[:limit])
        end

        if params[:start].present?
          phone_numbers = phone_numbers.offset(params[:start])
        end

        phone_numbers = phone_numbers.uniq.order(sanitize_sql_array(['%s %s', sort, dir]))

        render :json => {success: true, total_count: total_count, phone_numbers: phone_numbers.all.collect(&:to_data_hash)}
      end

=begin

 @api {get} /api/v1/phone_numbers/:id Index
 @apiVersion 1.0.0
 @apiName GetPhoneNumbers
 @apiGroup PhoneNumber
 
 @apiParam (path) {Number} id Id of PhoneNumber

 @apiSuccess (200) {Object} get_phone_number_response Response
 @apiSuccess (200) {Boolean} get_phone_number_response/success True if the request was successful
 @apiSuccess (200) {Number} get_phone_number_response.total_count Total count of records based on any filters applied
 @apiSuccess (200) {Object} get_phone_number_response.phone_number Phone Number record
 @apiSuccess (200) {Number} get_phone_number_response.phone_number.id Id of PhoneNumber

=end

      def show
        render json: {success: true, phone_number: PhoneNumber.find(params[:id]).to_data_hash}
      end

=begin

  @api {post} /api/v1/phone_numbers Create
  @apiVersion 1.0.0
  @apiName CreatePhoneNumber
  @apiGroup PhoneNumber

  @apiParam (body) {String} [contact_purposes] Comma delimitted string of ContactPurpose internal identifiers to filter by
  @apiParam (body) {String} phone_number Email Address
  @apiParam (body) {String} description Description of Email Address

  @apiSuccess (200) {Object} create_phone_number_response Response
  @apiSuccess (200) {Boolean} create_phone_number_response.success True if the request was successful
  @apiSuccess (200) {Object} create_phone_number_response.phone_number PhoneNumber record
  @apiSuccess (200) {Number} create_phone_number_response.phone_number.id Id of PhoneNumber

=end

      def create
        begin
          ActiveRecord::Base.transaction do
            phone_number = PhoneNumber.create(phone_number: params[:phone_number],
                                              description: params[:description])

            if params[:party_id].present?
              phone_number.contact.contact_record = Party.find(params[:party_id])
              phone_number.contact.save!
            end

            if params[:contact_purposes].present?
              params[:contact_purposes].split(',').each do |contact_purpose_iid|
                phone_number.contact.contact_purposes << ContactPurpose.iid(contact_purpose_iid)
              end
            end

            if params[:is_primary].present?
              phone_number.contact.is_primary = (params[:is_primary].to_bool === true)
            end

            phone_number.created_by_party = current_user.party
            phone_number.contact.save!
            phone_number.save!

            render :json => {success: true, phone_number: phone_number.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: ex.message}
        end
      end

=begin

  @api {put} /api/v1/phone_numbers/:id Update
  @apiVersion 1.0.0
  @apiName UpdatePhoneNumber
  @apiGroup PhoneNumber

  @apiParam (path) {Number} id Id of PhoneNumber

  @apiParam (body) {String} [contact_purposes] Comma delimitted string of ContactPurpose internal identifiers to filter by
  @apiParam (body) {String} [phone_number] Email Address
  @apiParam (body) {String} [description] Description of Email Address
   
  @apiSuccess (200) {Object} update_phone_number_response Response 
  @apiSuccess (200) {Boolean} update_phone_number_response.success True if the request was successful
  @apiSuccess (200) {Object} update_phone_number_response.phone_number PhoneNumber record
  @apiSuccess (200) {Number} update_phone_number_response.phone_number.id Id of PhoneNumber

=end

      def update
        begin
          ActiveRecord::Base.transaction do
            phone_number = PhoneNumber.find(params[:id])

            if params[:description].present?
              phone_number.description = params[:description]
            end

            if params[:phone_number].present?
              phone_number.phone_number = params[:phone_number]
            end

            if params[:contact_purposes].present?
              phone_number.contact.contact_purposes.delete_all

              params[:contact_purposes].split(',').each do |contact_purpose_iid|
                phone_number.contact.contact_purposes << ContactPurpose.iid(contact_purpose_iid)
              end
            end

            if params[:is_primary].present?
              phone_number.contact.is_primary = (params[:is_primary].to_bool === true)
            end

            phone_number.contact.save!
            phone_number.save!

            phone_number.updated_by_party = current_user.party
            phone_number.save!

            render :json => {success: true, phone_number: phone_number.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: ex.message}
        end
      end

=begin

  @api {delete} /api/v1/phone_numbers/:id Delete
  @apiVersion 1.0.0
  @apiName DeletePhoneNumber
  @apiGroup PhoneNumber

  @apiParam (path) {Number} id Id of PhoneNumber
 
  @apiSuccess (200) {Object} delete_phone_number_response Response 
  @apiSuccess (200) {Boolean} delete_phone_number_response.success True if the request was successful

=end

      def destroy
        phone_number = PhoneNumber.find(params[:id])

        render json: {success: phone_number.destroy}
      end

    end # PhoneNumbersController
  end # V1
end # API
