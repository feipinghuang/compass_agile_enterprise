module API
  module V1
    class ProductTypesController < BaseController

=begin

 @api {get} /api/v1/product_types
 @apiVersion 1.0.0
 @apiName GetProductTypes
 @apiGroup ProductType
 @apiDescription Get Product Types

 @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
 @apiParam (query) {String} [query_filter] JSON string of data to filter by
 @apiParam (query) {String} [context] JSON string of data in regards to the context the api is being called, {"view": "mobile"}
 @apiParam (query) {String} [query] String to query the ProductTypes by

 @apiSuccess (200) {Object} get_product_types_response Response.
 @apiSuccess (200) {Boolean} get_product_types_response.success True if the request was successful
 @apiSuccess (200) {Number} get_product_types_response.total_count Total count of ProductType records
 @apiSuccess (200) {Object[]} get_product_types_response.product_types List of ProductType records
 @apiSuccess (200) {Number} get_product_types_response.product_types.id Id of ProductType

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

        # TODO: fixed in another branch?
        unless params[:limit].blank?
          limit = params[:limit].to_i
        end

        unless params[:start].blank?
          start = params[:start].to_i
        end

        #query_filter = {}

        query_filter = params[:query_filter].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:query_filter]))
        context = params[:context].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:context]))

        # adjust the query filter for discount panels
        if( params[:panel_type] == 'SearchResults' || params[:panel_type] == 'ProductsIncluded')
          query_filter[:roots_only] = true
        end

        if params[:query]
          query_filter[:keyword] = params[:query].strip
        end

        # hook method to apply any scopes passed via parameters to this api
        product_types = ProductType.apply_filters(query_filter)
        #
        # scope by dba_organizations if there are no parties passed as filters
        unless query_filter[:party]
          dba_organizations = [current_user.party.dba_organization]
          dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
          product_types = product_types.scope_by_dba_organization(dba_organizations)
        end

        if sort and dir
          product_types = product_types.order("#{sort} #{dir}")
        end

        total_count = product_types.count

        if start and limit
          product_types = product_types.offset(start).limit(limit)
        end

        product_types = product_types.order('description')

        # special handling for discounts custom views
        # is indicated by the presence of discountView
        # parameter
        if params[:discountView].blank?
          if context[:view]
            if context[:view] == 'mobile'
              render :json => {success: true,
                               total: total_count,
                               product_types: product_types.collect { |product_type| product_type.to_mobile_hash }}
            end
          else
            render :json => {success: true,
                             total: total_count,
                             product_types: product_types.collect { |product_type| product_type.to_data_hash }}
          end
        else
          # special handling for discounts custom views
          # uses a tree, may have node parameter
          if params[:node].blank? || params[:node] == 'root'
            # only take roots
            # need to apply some funky filtering
            product_type_ids = product_types.collect{|product_type| product_type.root.id}.uniq
            product_type_ids = filtered_roots(query_filter, product_type_ids, params)
          else
            # take descendants of node
            descendant_ids = ProductType.find(params[:node]).descendants.collect(&:id)
            statement = ProductType
            product_type_ids = statement.where(ProductType.arel_table[:id].in(descendant_ids)).all.collect do |node|
              node.self_and_ancestors.collect do |ancestor|
                ancestor.id
              end
            end
            product_type_ids = product_type_ids.flatten.uniq
            # determine which children are in the discount already and exclude them
            product_type_ids = filtered_node(query_filter, product_type_ids, params)
          end
          if product_type_ids.count > 0
            product_types = ProductType.where("id in (#{product_type_ids.join(',')})")
            total_count = product_types.count
          else
            product_types = []
            total_count = 0
          end

          render :json => {success: true,
                           total: total_count,
                           product_types: product_types.collect { |product_type| product_type.to_offer_hash() }}
        end
      end
=begin

 @api {get} /api/v1/product_types/:id
 @apiVersion 1.0.0
 @apiName GetProductType
 @apiGroup ProductType
 @apiDescription Get Product Type

 @apiParam (query) {Integer} id Id of ProductType

 @apiSuccess (200) {Object} get_product_type_response Response.
 @apiSuccess (200) {Boolean} get_product_type_response.success True if the request was successful
 @apiSuccess (200) {Object} get_product_types_response.product_type ProductType record
 @apiSuccess (200) {Number} get_product_types_response.product_type.id Id of ProductType

=end


      def show
        product_type = ProductType.find(params[:id])

        respond_to do |format|
          # if a tree format was requested then respond with the children of this ProductType
          format.tree do
            render :json => {success: true, product_types: ProductType.where(parent_id: product_type).order("sequence ASC").collect { |child| child.to_data_hash }}
          end

          # if a json format was requested then respond with the ProductType in json format
          format.json do
            render :json => {success: true, product_type: product_type.to_data_hash}
          end
        end

      render :json => {success: true,
                       product_type: product_type.to_data_hash}
    end

=begin

 @api {post} /api/v1/product_types/
 @apiVersion 1.0.0
 @apiName CreateProductType
 @apiGroup ProductType
 @apiDescription Create Product Type

 @apiParam (body) {String} description Description
 @apiParam (body) {String} sku SKU to set
 @apiParam (body) {String} unit_of_masurement Internal Identifier of UnitOfMeasurement
 @apiParam (body) {String} [comment] Comment to set
 @apiParam (body) {String} [party_role] RoleType Internal Identifier to set for the passed party
 @apiParam (body) {Number} [party_id] Id of Party to associate to this ProductType, used to associate a Vendor to a ProductType for example
 @apiSuccess (200) {Object} create_product_type_response Response.

 @apiSuccess (200) {Boolean} create_product_type_response.success True if the request was successful
 @apiSuccess (200) {Object} create_product_type_response.product_type ProductType record
 @apiSuccess (200) {Number} create_product_type_response.product_type.id Id of ProductType

=end


      def create
        begin
          ActiveRecord::Base.transaction do
            product_type = ProductType.new
            product_type.description = params[:description]
            product_type.sku = params[:sku]
            product_type.unit_of_measurement_id = params[:unit_of_measurement]
            product_type.comment = params[:comment]

            product_type.created_by_party = current_user.party

            product_type.save!

            #
            # For scoping by party, add party_id and role_type 'vendor' to product_party_roles table. However may want to override controller elsewhere
            # so that default is no scoping in erp_products engine
            #
            party_role = params[:party_role]
            party_id = params[:party_id]
            unless party_role.blank? or party_id.blank?
              product_type_party_role = ProductTypePtyRole.new
              product_type_party_role.product_type = product_type
              product_type_party_role.party_id = party_id
              product_type_party_role.role_type = RoleType.iid(party_role)
              product_type_party_role.save
            end
          end

          render :json => {success: true,
                           product_type: product_type.to_data_hash}

        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not create product type'}
        end
      end
=begin

 @api {put} /api/v1/product_types/:id
 @apiVersion 1.0.0
 @apiName UpdateProductType
 @apiGroup ProductType
 @apiDescription Update Product Type

 @apiParam (query) {Integer} id Id of ProductType
 @apiParam (body) {String} [description] Description
 @apiParam (body) {String} [sku] SKU to set
 @apiParam (body) {String} [unit_of_masurement] Internal Identifier of UnitOfMeasurement
 @apiParam (body) {String} [comment] Comment to set

 @apiSuccess (200) {Object} update_product_type_response Response.
 @apiSuccess (200) {Boolean} update_product_type_response.success True if the request was successful
 @apiSuccess (200) {Object} update_product_type_response.product_type ProductType record
 @apiSuccess (200) {Number} update_product_type_response.product_type.id Id of ProductType

=end


    def update
        begin
          ActiveRecord::Base.transaction do
            product_type = ProductType.find(params[:id])

            product_type.description = params[:description]
            product_type.sku = params[:sku]
            product_type.unit_of_measurement_id = params[:unit_of_measurement]
            product_type.comment = params[:comment]

            product_type.updated_by_party = current_user.party

            product_type.save!

            render :json => {success: true,
                             product_type: product_type.to_data_hash}
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

 @api {delete} /api/v1/product_types/:id
 @apiVersion 1.0.0
 @apiName DeleteProductType
 @apiGroup ProductType
 @apiDescription Delete Product Type

 @apiParam (param) {Integer} id Id of record to delete

 @apiSuccess (200) {Object} delete_product_type_response Response.
 @apiSuccess (200) {Boolean} delete_product_type_response.success True if the request was successful

=end

    def destroy
        ProductType.find(params[:id]).destroy

        render :json => {:success => true}
    end

    private

      def filtered_roots(filters, product_type_ids, params)

        # There are two panels: SearchResults and ProductsIncluded.
        # Both are trees of product types.
        # When the call is for roots (as opposed to nodes), we
        # only want to include the root if at least child is included
        # in the discount for ProductIncluded or at least one child is
        # not included for the SearchResults
        filtered_product_type_ids = []

        if(params[:panel_type] == 'SearchResults')
          current_discount_id = filters[:exclude_discount_id]
          product_type_ids.each do |product_type_id|
            product_type = ProductType.find(product_type_id)
            if product_type.at_least_one_child_not_in_discount?(current_discount_id)
              filtered_product_type_ids << product_type.id
            end
          end
        else
          current_discount_id = filters[:discount_id]
          product_type_ids.each do |product_type_id|
            product_type = ProductType.find(product_type_id)
            if product_type.at_least_one_child_in_discount?(current_discount_id)
              filtered_product_type_ids << product_type.id
            end
          end
        end

        filtered_product_type_ids
      end

      def filtered_node(filters, product_type_ids, params)
        # There are two panels: SearchResults and ProductsIncluded.
        # Both are trees of product types.
        # When the call is for nodes (as opposed to roots), we
        # only want to include the node if it is included
        # in the discount for ProductIncluded or
        # not included for the SearchResults

        filtered_product_type_ids = []

        if(params[:panel_type] == 'SearchResults')
          current_discount_id = filters[:exclude_discount_id]
          product_type_ids.each do |product_type_id|
            product_type = ProductType.find(product_type_id)
            if product_type.root?
            else
              product_type_discount =  ProductTypeDiscount.where("discount_id = ? and product_type_id = ?", current_discount_id, product_type.id)
              if product_type_discount.empty?
                filtered_product_type_ids << product_type.id
              end
            end
          end
        else
          current_discount_id = filters[:discount_id]
          product_type_ids.each do |product_type_id|
            product_type = ProductType.find(product_type_id)
            if product_type.root?
            else
              product_type_discount =  ProductTypeDiscount.where("discount_id = ? and product_type_id = ?", current_discount_id, product_type.id)
              if !product_type_discount.empty?
                filtered_product_type_ids << product_type.id
              end
            end
          end
        end

        filtered_product_type_ids

      end

    end # ProductTypesController
  end # V1
end # API