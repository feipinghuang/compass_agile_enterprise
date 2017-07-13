module API
  module V1
    class ProductOptionTypesController < BaseController

=begin

  @api {get} /api/v1/product_option_types
  @apiVersion 1.0.0
  @apiName GetProductOptionTypes
  @apiGroup ProductOptionType
  @apiDescription Get Product Option Type

  @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam (query) {Number} [id] Id to filter by

  @apiSuccess (200) {Object} get_product_option_types_response Response.
  @apiSuccess (200) {Boolean} get_product_option_types_response.success If the request was sucessful
  @apiSuccess (200) {Number} get_product_option_types_response.total_count Total count of records 
  @apiSuccess (200) {Object[]} get_product_option_types_response.product_option_types ProductOptionType records
  @apiSuccess (200) {Integer} get_product_option_types_response.product_option_types.id Id of ProductOptionType record

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

        product_option_types = ProductOptionType.by_tenant(current_user.party.dba_organization)

        if params[:id]
          product_option_types.where(id: params[:id])
        end

        if sort and dir
          product_option_types = product_option_types.order("#{sort} #{dir}")
        end

        total_count = product_option_types.count

        if start and limit
          product_option_types = product_option_types.offset(start).limit(limit)
        end

        render :json => {success: true,
                         total_count: total_count,
                         product_option_types: product_option_types.collect(&:to_data_hash)}

      end

    end # ProductOptionTypesController
  end # V1
end # API
