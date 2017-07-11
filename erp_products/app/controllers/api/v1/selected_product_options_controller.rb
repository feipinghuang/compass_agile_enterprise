module API
  module V1
    class SelectedProductOptionsController < BaseController

=begin

  @api {get} /api/v1/selected_product_options
  @apiVersion 1.0.0
  @apiName GetSelectedProductOptions
  @apiGroup SelectedProductOption
  @apiDescription Get Selected Product Options  

  @apiParam {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam {Number} [start] Start for paging
  @apiParam {Number} [offset] Offset for paging
  @apiParam {Number} [product_option_type_id] Id of ProductOptionType to filter by
  @apiParam {String} [selected_record_type] Type of Selected Record to scope by
  @apiParam {Number} [selected_record_id] Id of Selected Record to scope by

  @apiSuccess (200) {Object} get_selected_product_options Response.
  @apiSuccess (200) {Boolean} get_selected_product_options.success If the request was sucessful
  @apiSuccess (200) {Number} get_selected_product_options.total_count Total count of records 
  @apiSuccess (200) {Object[]} get_selected_product_options.selected_product_options SelectedProductOption records
  @apiSuccess (200) {Integer} get_selected_product_options.selected_product_options.id Id SelectedProductOption record      

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
        end

        if params[:start] && params[:offset]
          limit = params[:limit] || 25
          start = params[:start] || 0
        end

        if params[:selected_record_type] && params[:selected_record_id]
          selected_product_options = SelectedProductOption.where('selected_option_record_type = ? and selected_option_record_id = ?', params[:selected_record_type], params[:selected_record_id])
        else
          raise 'selected_record_type and selected_record_id are required'
        end

        if sort and dir
          selected_product_options = selected_product_options.order("#{sort} #{dir}")
        end

        total_count = selected_product_options.count

        if start and limit
          selected_product_options = selected_product_options.offset(start).limit(limit)
        end

        render :json => {success: true,
                         total_count: total_count,
                         selected_product_options: selected_product_options.collect(&:to_data_hash)}

      end

    end # SelectedProductOptionsController
  end # V1
end # API
