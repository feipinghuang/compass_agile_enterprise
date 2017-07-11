module API
  module V1
    class ProductOptionApplicabilitiesController < BaseController

=begin

  @api {get} /api/v1/product_option_applicabilities
  @apiVersion 1.0.0
  @apiName GetProductOptionApplicabilities
  @apiGroup ProductOptionApplicability
  @apiDescription Get Product Option Applicability

  @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam (query) {Integer} [product_type_id] ProductType Id to filter by

  @apiSuccess (200) {Object} get_product_option_applicabilities_response Response.
  @apiSuccess (200) {Boolean} get_product_option_applicabilities_response.success If the request was sucessful
  @apiSuccess (200) {Integer} get_product_option_applicabilities_response.total_count Total count of records   
  @apiSuccess (200) {Object[]} get_product_option_applicabilities_response.product_option_applicabilities ProductOptionApplicability records
  @apiSuccess (200) {Integer} get_product_option_applicabilities_response.product_option_applicabilities.id Id of ProductOptionApplicability

=end

      def index
        sort = nil
        dir = nil
        limit = nil
        start = nil

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'description'
          dir = sort_hash[:direction] || 'ASC'
          limit = params[:limit] || 25
          start = params[:start] || 0
        end

        if params[:product_type_id]
          product_option_applicabilities = ProductOptionApplicability.joins("inner join product_types on product_types.id = product_option_applicabilities.optioned_record_id
                                                                             and product_option_applicabilities.optioned_record_type = 'ProductType'")
          .where(product_types: {id: params[:product_type_id]})
        else
          raise 'Product Type Id is required'
        end

        if sort and dir
          product_option_applicabilities = product_option_applicabilities.order("#{sort} #{dir}")
        end

        total_count = product_option_applicabilities.count

        if start and limit
          product_option_applicabilities = product_option_applicabilities.offset(start).limit(limit)
        end

        render :json => {success: true,
                         total_count: total_count,
                         product_option_applicabilities: product_option_applicabilities.collect(&:to_data_hash)}

      end

=begin

  @api {get} /api/v1/product_option_applicabilities/update_positions
  @apiVersion 1.0.0
  @apiName UpdateProductOptionApplicabilityPositions
  @apiGroup ProductOptionApplicability
  @apiDescription Update Product Option Applicability Positions

  @apiParam (query) {String} [positions] JSON string of position array data [1,2,3]

  @apiSuccess (200) {Object} product_option_applicabilities_update_positions_response Response.
  @apiSuccess (200) {Boolean} product_option_applicabilities_update_positions_response.success If the request was sucessful  

=end

      def update_positions
        position = 0

        begin
          ActiveRecord::Base.transaction do
            JSON.parse(params[:positions]).each do |id|
              product_option_applicability = ProductOptionApplicability.find(id)
              product_option_applicability.position = position
              product_option_applicability.save!

              position += 1
            end

            render :json => {success: true}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not update positions'}
        end
      end

=begin

  @api {get} /api/v1/product_option_applicabilities/:id
  @apiVersion 1.0.0
  @apiName GetProductOptionApplicability
  @apiGroup ProductOptionApplicability
  @apiDescription Show Product Option Applicability   

  @apiSuccess (200) {Object} show_product_option_applicabilities_response Response.
  @apiSuccess (200) {Boolean} show_product_option_applicabilities_response.success If the request was sucessful   
  @apiSuccess (200) {Object} show_product_option_applicabilities_response.product_option_applicability ProductOptionApplicability record
  @apiSuccess (200) {Number} show_product_option_applicabilities_response.product_option_applicability.id Id of ProductOptionApplicability  

=end

      def show
        product_option_applicability = ProductOptionApplicability.find(params[:id])

        render :json => {success: true,
                         product_option_applicability: product_option_applicability.to_data_hash}
      end

=begin

  @api {post} /api/v1/product_option_applicabilities
  @apiVersion 1.0.0
  @apiName CreateProductOptionApplicability
  @apiGroup ProductOptionApplicability
  @apiDescription Create Product Option Applicability 

  @apiParam (body) {Integer} product_type_id Id of ProductType
  @apiParam (body) {String} description Description
  @apiParam (body) {String} product_option_type_id Id of ProductOptionType
  @apiParam (body) {Boolean} [multi_select] If it should be Multi Select
  @apiParam (body) {Boolean} [required] If it should be required

  @apiSuccess (200) {Object} create_product_option_applicabilities_response Response.
  @apiSuccess (200) {Object} create_product_option_applicabilities_response.product_option_applicability ProductOptionApplicability record
  @apiSuccess (200) {Number} create_product_option_applicabilities_response.product_option_applicability.id Id of ProductOptionApplicability  

=end

      def create
        begin
          ActiveRecord::Base.transaction do
            product_option_applicability = ProductOptionApplicability.new

            product_option_applicability.description = params[:description]
            product_option_applicability.product_option_type_id = params[:product_option_type_id]

            if params[:multi_select] === true
              product_option_applicability.multi_select = true
            elsif params[:multi_select] === false
              product_option_applicability.multi_select = false
            end

            if params[:required] === true
              product_option_applicability.required = true
            elsif params[:required] === false
              product_option_applicability.required = false
            end

            if params[:product_type_id]
              product_option_applicability.optioned_record_id = params[:product_type_id]
              product_option_applicability.optioned_record_type = 'ProductType'
            else
              raise 'Product Type Id is required'
            end

            product_option_applicability.created_by_party = current_user.party

            product_option_applicability.save!

            render :json => {success: true,
                             product_option_applicability: product_option_applicability.to_data_hash}
          end

        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not create product option applicability'}
        end
      end

=begin

  @api {put} /api/v1/product_option_applicabilities/:id Update
  @apiVersion 1.0.0
  @apiName UpdateProductOptionApplicability
  @apiGroup ProductOptionApplicability
  @apiDescription Update Product Option Applicability  
  
  @apiParam (body) {String} [description] Description
  @apiParam (body) {String} [product_option_type_id] Id of ProductOptionType
  @apiParam (body) {Boolean} [multi_select] If it should be Multi Select
  @apiParam (body) {Boolean} [required] If it should be required

  @apiSuccess (200) {Object} update_product_option_applicabilities_response Response.
  @apiSuccess (200) {Boolean} update_product_option_applicabilities_response.success If the request was sucessful     
  @apiSuccess (200) {Object} update_product_option_applicabilities_response.product_option_applicability ProductOptionApplicability record
  @apiSuccess (200) {Number} update_product_option_applicabilities_response.product_option_applicability.id Id of ProductOptionApplicability 

=end

      def update
        begin
          ActiveRecord::Base.transaction do
            product_option_applicability = ProductOptionApplicability.find(params[:id])

            if params[:description].present?
              product_option_applicability.description = params[:description]
            end

            if params[:product_option_type_id].present?
              product_option_applicability.product_option_type_id = params[:product_option_type_id]
            end

            if params[:multi_select] === true
              product_option_applicability.multi_select = true
            elsif params[:multi_select] === false
              product_option_applicability.multi_select = false
            end

            if params[:required] === true
              product_option_applicability.required = true
            elsif params[:required] === false
              product_option_applicability.required = false
            end

            product_option_applicability.updated_by_party = current_user.party

            product_option_applicability.save!

            render :json => {success: true,
                             product_option_applicability: product_option_applicability.to_data_hash}
          end

        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not update product option applicability'}
        end
      end

=begin

  @api {delete} /api/v1/product_option_applicabilities/:id
  @apiVersion 1.0.0
  @apiName DeleteProductOptionApplicability
  @apiGroup ProductOptionApplicability
  @apiDescription Delete Product Option Applicability

  @apiParam (param) {Integer} id Id of record to delete 

  @apiSuccess (200) {Object} delete_product_option_applicabilities_response Response.
  @apiSuccess (200) {Boolean} delete_product_option_applicabilities_response.success If the request was sucessful  

=end

      def destroy
        ProductOptionApplicability.find(params[:id]).destroy

        render :json => {:success => true}
      end

    end # ProductOptionApplicabilitiesController
  end # V1
end # API
