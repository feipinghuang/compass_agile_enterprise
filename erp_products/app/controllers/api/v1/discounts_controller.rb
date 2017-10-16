module API
  module V1
    class DiscountsController < BaseController

=begin
 @api {get} /api/v1/discounts
 @apiVersion 1.0.0
 @apiName GetDiscounts
 @apiGroup Discounts
 @apiDescription Get Discounts

 @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
 @apiParam (query) {String} [query_filter] JSON string of data to filter by
 @apiParam (query) {String} [context] JSON string of data in regards to the context the api is being called, {"view": "mobile"}
 @apiParam (query) {String} [query] String to query the Discounts by

 @apiSuccess (200) {Object} get_discounts_response Response.
 @apiSuccess (200) {Boolean} get_discounts_response.success True if the request was successful
 @apiSuccess (200) {Number} get_discounts_response.total_count Total count of Discount records
 @apiSuccess (200) {Object[]} get_discounts_response.discounts List of Discount records
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

        query_filter = params[:query_filter].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:query_filter]))
        context = params[:context].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:context]))

        if params[:query]
          query_filter[:keyword] = params[:query].strip
        end

        # hook method to apply any scopes passed via parameters to this api
        discounts = Discount.apply_filters(query_filter)

        # scope by dba_organizations if there are no parties passed as filters
        # unless query_filter[:party]
        #   dba_organizations = [current_user.party.dba_organization]
        #   dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
        #   discounts = discounts.scope_by_dba_organization(dba_organizations)
        # end

        if sort and dir
          discounts = discounts.order("#{sort} #{dir}")
        end

        total_count = discounts.count

        if start and limit
          discounts = discounts.offset(start).limit(limit)
        end

        discounts = discounts.order('description')

        if context[:view]
          if context[:view] == 'mobile'
            render :json => {success: true,
                             total_count: total_count,
                             discounts: discounts.collect { |discount| discount.to_mobile_hash }}
          end
        else
          render :json => {success: true,
                           total_count: total_count,
                           discounts: discounts.collect { |discount| discount.to_data_hash }}
        end

      end
=begin
 @api {get} /api/v1/discounts/:id
 @apiVersion 1.0.0
 @apiName GetDiscount
 @apiGroup Discount
 @apiDescription Get Discount
 @apiParam (query) {Integer} id Id of discount
 @apiSuccess (200) {Object} get_discount_response Response.
 @apiSuccess (200) {Boolean} get_discount_response.success True if the request was successful
 @apiSuccess (200) {Object} get_discounts_response.discount discount record

=end


      def show
        discount = Discount.find(params[:id].to_i)

        # respond_to do |format|
        #
        #   # if a json format was requested then respond with the discount in json format
        #   format.json do
        #     render :json => {success: true, discount: discount.to_data_hash}
        #   end
        # end

        render :json => {success: true,
                         discount: discount.to_data_hash}
      end

=begin
 @api {post} /api/v1/discounts/
 @apiVersion 1.0.0
 @apiName CreateDiscount
 @apiGroup Discount
 @apiDescription Create Discount
 @apiParam (body) {String} description Description
 @apiParam (body) {String} discount_type Discount Type
 @apiParam (body) {Number} amount Amount
 @apiParam (body) {Boolean} date_constrained Date Constrained
 @apiParam (body) {DateTime} Valid From / Time window for discount validity. Value should be UTC; YYYY-MM-DDTHH:MM:SS+00:00
 @apiParam (body) {DateTime} Valid Thru / Time window for discount validity. Value should be UTC; YYYY-MM-DDTHH:MM:SS+00:00
 @apiParam (body) {Boolean} round Round / Whether final price should artifically rounded
 @apiParam (body) {Number} round_amount Round Amount
 @apiSuccess (200) {Object} create_discount_response Response.
 @apiSuccess (200) {Boolean} create_discount_response.success True if the request was successful
 @apiSuccess (200) {Object} create_discount_response.discount discount record
=end


      def create
        begin
          ActiveRecord::Base.transaction do
            discount = Discount.new
            discount.description = params[:description]
            discount.discount_type = params[:discount_type]
            discount.amount = params[:amount].present? ? BigDecimal.new(params[:amount]) : nil
            discount.date_constrained = params[:date_constrained].to_bool
            discount.valid_from = params[:valid_from].present? ? DateTime.parse(params[:valid_from]) : nil
            discount.valid_thru = params[:valid_thru].present? ? DateTime.parse(params[:valid_thru]) : nil
            discount.round = params[:round].to_bool
            discount.round_amount = params[:round_amount].present? ? BigDecimal.new(params[:round_amount]) : nil

            discount.created_by_party = current_user.party

            discount.save!

            discount.generate_product_offers(CSV.parse(params[:product_types]).first, '')

            render :json => {success: true,
                             discount: discount.to_data_hash}

          end


        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not create discount'}
        end


      end
=begin
 @api {put} /api/v1/discounts/:id
 @apiVersion 1.0.0
 @apiName UpdateDiscount
 @apiGroup Discount
 @apiDescription Update Discount
 @apiParam (query) {Integer} id Id of Discount
 @apiParam (body) {String} description Description
 @apiParam (body) {String} discount_type Discount Type
 @apiParam (body) {Number} amount Amount
 @apiParam (body) {Boolean} date_constrained Date Constrained
 @apiParam (body) {DateTime} Valid From / Time window for discount validity. Value should be UTC; YYYY-MM-DDTHH:MM:SS+00:00
 @apiParam (body) {DateTime} Valid Thru / Time window for discount validity. Value should be UTC; YYYY-MM-DDTHH:MM:SS+00:00
 @apiParam (body) {Boolean} round Round / Whether final price should artifically rounded
 @apiParam (body) {Number} round_amount Round Amount
 @apiSuccess (200) {Object} update_discount_response Response.
 @apiSuccess (200) {Boolean} update_discount_response.success True if the request was successful
 @apiSuccess (200) {Object} update_discount_response.discount discount record
=end


      def update
        begin
          ActiveRecord::Base.transaction do
            discount = Discount.find(params[:id].to_i)
            discount.description = params[:description]
            discount.discount_type = params[:discount_type]
            discount.amount = params[:amount].present? ? BigDecimal.new(params[:amount]) : nil
            discount.date_constrained = params[:date_constrained].to_bool
            discount.valid_from = params[:valid_from].present? ? DateTime.parse(params[:valid_from]) : nil
            discount.valid_thru = params[:valid_thru].present? ? DateTime.parse(params[:valid_thru]) : nil
            discount.round = params[:round].to_bool
            discount.round_amount = params[:round_amount].present? ? BigDecimal.new(params[:round_amount]) : nil

            discount.updated_by_party = current_user.party

            discount.save!

            discount.generate_product_offers(CSV.parse(params[:product_types]).first)

            render :json => {success: true,
                             discount: discount.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not update product type'}
        end
      end

=begin
 @api {delete} /api/v1/discounts/:id
 @apiVersion 1.0.0
 @apiName DestroyDiscount
 @apiGroup Discount
 @apiDescription Destroy Discount
 @apiParam (param) {Integer} id Id of record to delete
 @apiSuccess (200) {Object} destroy_discount_response Response.
 @apiSuccess (200) {Boolean} destroy_discount_response.success True if the request was successful
=end

      def destroy
        Discount.find(params[:id]).destroy

        render :json => {:success => true}
      end



      def add_products_to_discount
        begin
          ActiveRecord::Base.transaction do

            if params[:product_type_ids].blank?
              # adding all: have to filter product types to get to what 'all' means since UI uses paging store
              # 'all' may not present in the UI
              query_filter = params[:query_filter].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:query_filter]))
              # adjust for search results
              query_filter[:roots_only] = true
              query_filter.delete(:target_id)
              # hook method to apply any scopes passed via parameters to this api
              product_types = ProductType.apply_filters(query_filter)
              product_type_ids = product_types.collect { |product_type| product_type.id }
            else
              product_type_ids = CSV.parse(params[:product_type_ids])[0].collect{ |id| id.to_i}
            end

            discount_id = params[:target_id].to_i

            discount = Discount.find(discount_id)

            product_type_ids.each do |product_type_id|

              product_type = ProductType.find(product_type_id)

                if product_type.is_base
                  discount_product_type_ids = product_type.children.collect { |children| children.id}
                  discount_product_type_ids.unshift(product_type_id)
                else
                  discount_product_type_ids = [product_type_id]
                  # add the parent too
                  discount_product_type_ids.unshift(product_type.parent.id)
                end

                discount.generate_product_offers(discount_product_type_ids, params[:product_tag])
            end

              render :json => {:success => true}
          end
            rescue => ex
              Rails.logger.error ex.message
              Rails.logger.error ex.backtrace.join("\n")

              # email error
              ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

              render :json => {success: false, message: 'Could not add product types to discount'}
          end
      end

      def remove_products_from_discount
      begin
        ActiveRecord::Base.transaction do

          if params[:product_type_ids].blank?
            product_type_ids = []
          else
            product_type_ids = CSV.parse(params[:product_type_ids])[0].collect{ |id| id.to_i}
          end

          discount_id = params[:target_id].to_i
          discount = Discount.find(discount_id)

          discount.remove_product_offers(product_type_ids, params[:product_tag])

          render :json => {:success => true}
        end
      rescue => ex
        Rails.logger.error ex.message
        Rails.logger.error ex.backtrace.join("\n")

        # email error
        ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

        render :json => {success: false, message: 'Could not delete product types from discount'}
      end
    end

    end # DiscountsController
  end # V1
end # API