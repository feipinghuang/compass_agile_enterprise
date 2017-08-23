module API
  module V1
    class ChargeTypesController < BaseController

=begin

  @api {get} /api/v1/charge_types Index
  @apiVersion 1.0.0
  @apiName GetChargeTypes
  @apiGroup ChargeTypes

  @apiSuccess {Boolean} success True if the request was successful
  @apiSuccess {Array} charge_types ChargeType records

=end

    	def index
    		sort = 'description'
        dir = 'ASC'

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'description'
          dir = sort_hash[:direction] || 'ASC'
        end
        limit = params[:limit] || 25
        start = params[:start] || 0

        charge_types = ChargeType.order('description asc')

        if params[:query]
          charge_types = charge_types.where(ChargeType.arel_table[:description].matches(params[:query] + '%'))
        end

        total_count = charge_types.count

        if params[:id]
          charge_types = charge_types.where(id: params[:id])
        end

        if sort and dir
          charge_types = charge_types.order("#{sort} #{dir}")
        end

        if start and limit
          charge_types = charge_types.offset(start).limit(limit)
        end

        render :json => {success: true,
                           total_count: total_count,
                           charge_types: charge_types.collect { |charge_type| charge_type.to_data_hash }}

    	end

=begin

 @api {get} /api/v1/charge_types/:id
 @apiVersion 1.0.0
 @apiName GetChargeType
 @apiGroup ChargeType
 @apiDescription Get Charge Type

 @apiParam (query) {Integer} id Id of ChargeType

 @apiSuccess (200) {Object} get_charge_type_response Response.
 @apiSuccess (200) {Boolean} get_charge_type_response.success True if the request was successful
 @apiSuccess (200) {Object} get_charge_types_response.charge_type ChargeType record
 @apiSuccess (200) {Number} get_charge_types_response.charge_type.id Id of ChargeType

=end

    	def show
    		charge_type = ChargeType.find(params[:id])

        render :json => {success: true,
                         charge_type: charge_type.to_data_hash}
    	end

=begin

 @api {post} /api/v1/charge_types/
 @apiVersion 1.0.0
 @apiName CreateChargeType
 @apiGroup ChargeType
 @apiDescription Create Charge Type

 @apiParam (body) {String} description Description

 @apiSuccess (200) {Object} create_charge_type_response Response.
 @apiSuccess (200) {Boolean} create_charge_type_response.success True if the request was successful
 @apiSuccess (200) {Object} create_charge_type_response.charge_type ChargeType record
 @apiSuccess (200) {Number} create_charge_type_response.charge_type.id Id of ChargeType

=end

    	def create
    		begin
          ActiveRecord::Base.transaction do
            charge_type = ChargeType.new
            charge_type.description = params[:description]

            charge_type.save!

            render :json => {success: true,
                             charge_type: charge_type.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not create charge type'}
        end
    	end

=begin

 @api {put} /api/v1/charge_types/:id
 @apiVersion 1.0.0
 @apiName UpdateChargeType
 @apiGroup ChargeType
 @apiDescription Update Charge Type

 @apiParam (body) {String} [description] Description

 @apiSuccess (200) {Object} update_charge_type_response Response.
 @apiSuccess (200) {Boolean} update_charge_type_response.success True if the request was successful
 @apiSuccess (200) {Object} update_charge_type_response.charge_type ChargeType record
 @apiSuccess (200) {Number} update_charge_type_response.charge_type.id Id of ChargeType

=end

    	def update
    		begin
          ActiveRecord::Base.transaction do
            charge_type = ChargeType.find(params[:id])

            if params[:description]
              charge_type.description = params[:description]
            end

            charge_type.save!

            render :json => {success: true,
                             charge_type: charge_type.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not update charge type'}
        end
    	end

=begin

 @api {delete} /api/v1/charge_types/:id
 @apiVersion 1.0.0
 @apiName DeleteChargeType
 @apiGroup ChargeType
 @apiDescription Delete Charge Type

 @apiParam (param) {Integer} id Id of record to delete 

 @apiSuccess (200) {Object} delete_charge_type_response Response.
 @apiSuccess (200) {Boolean} delete_charge_type_response.success True if the request was successful

=end

      def destroy
        ChargeType.find(params[:id]).destroy

        render :json => {:success => true}
      end


    end # ChargeTypesController
  end # V1
end # API
