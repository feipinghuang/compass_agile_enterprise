module API
  module V1
    class CollectionsController < BaseController

=begin
 @api {get} /api/v1/collections
 @apiVersion 1.0.0
 @apiName GetCollections
 @apiGroup Collections
 @apiDescription Get Collections

 @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
 @apiParam (query) {String} [query_filter] JSON string of data to filter by
 @apiParam (query) {String} [context] JSON string of data in regards to the context the api is being called, {"view": "mobile"}
 @apiParam (query) {String} [query] String to query the Collections by

 @apiSuccess (200) {Object} get_collections_response Response.
 @apiSuccess (200) {Boolean} get_collections_response.success True if the request was successful
 @apiSuccess (200) {Number} get_collections_response.total_count Total count of Collection records
 @apiSuccess (200) {Object[]} get_collections_response.collections List of Collection records
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
        collections = Collection.apply_filters(query_filter)

        # scope by dba_organizations if there are no parties passed as filters
        # unless query_filter[:party]
        #   dba_organizations = [current_user.party.dba_organization]
        #   dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
        #   collections = collections.scope_by_dba_organization(dba_organizations)
        # end

        if sort and dir
          collections = collections.order("#{sort} #{dir}")
        end

        total_count = collections.count

        if start and limit
          collections = collections.offset(start).limit(limit)
        end

        collections = collections.order('name')

        if context[:view]
          if context[:view] == 'mobile'
            render :json => {success: true,
                             total_count: total_count,
                             collections: collections.collect { |collection| collection.to_mobile_hash }}
          end
        else
          render :json => {success: true,
                           total_count: total_count,
                           collections: collections.collect { |collection| collection.to_data_hash }}
        end

      end
=begin
 @api {get} /api/v1/collections/:id
 @apiVersion 1.0.0
 @apiName GetCollection
 @apiGroup Collection
 @apiDescription Get Collection
 @apiParam (query) {Integer} id Id of collection
 @apiSuccess (200) {Object} get_collection_response Response.
 @apiSuccess (200) {Boolean} get_collection_response.success True if the request was successful
 @apiSuccess (200) {Object} get_collections_response.collection collection record

=end


      def show
        collection = Collection.find(params[:id].to_i)

        render :json => {success: true,
                         collection: collection.to_data_hash}
      end

=begin
 @api {post} /api/v1/collections/
 @apiVersion 1.0.0
 @apiName CreateCollection
 @apiGroup Collection
 @apiDescription Create Collection
 @apiParam (body) {String} description Description
=end


      def create
        begin
          ActiveRecord::Base.transaction do
            collection = Collection.new
            collection.name = params[:name]
            collection.internal_identifier = params[:name].to_iid
            collection.description = params[:description]


            collection.save!

            render :json => {success: true,
                             collection: collection.to_data_hash}

          end


        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not create collection'}
        end


      end
=begin
 @api {put} /api/v1/collections/:id
 @apiVersion 1.0.0
 @apiName UpdateCollection
 @apiGroup Collection
 @apiDescription Update Collection
 @apiParam (query) {Integer} id Id of Collection
 @apiParam (body) {String} description Description
=end

      def update
        begin
          ActiveRecord::Base.transaction do
            collection.name = params[:name]
            collection.internal_identifier = params[:name].to_iid
            collection.description = params[:description]
            collection.save!

            render :json => {success: true,
                             collection: collection.to_data_hash}
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
 @api {delete} /api/v1/collections/:id
 @apiVersion 1.0.0
 @apiName DestroyCollection
 @apiGroup Collection
 @apiDescription Destroy Collection
 @apiParam (param) {Integer} id Id of record to delete
 @apiSuccess (200) {Object} destroy_collection_response Response.
 @apiSuccess (200) {Boolean} destroy_collection_response.success True if the request was successful
=end

      def destroy
        Collection.find(params[:id]).destroy

        render :json => {:success => true}
      end


      def add_products_to_collection
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

            collection_id = params[:target_id].to_i

            collection = Collection.find(collection_id)

            product_type_ids.each do |product_type_id|

              product_type = ProductType.find(product_type_id)

              if product_type.is_base
                collection_product_type_ids = product_type.children.collect { |children| children.id}
                collection_product_type_ids.unshift(product_type_id)
              else
                collection_product_type_ids = [product_type_id]
                # add the parent too
                collection_product_type_ids.unshift(product_type.parent.id)
              end

              collection.add_products(collection_product_type_ids, params[:product_tag])
            end

            render :json => {:success => true}
          end
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not add product types to collection'}
        end
      end

      def remove_products_from_collection
        begin
          ActiveRecord::Base.transaction do

            if params[:product_type_ids].blank?
              product_type_ids = []
            else
              product_type_ids = CSV.parse(params[:product_type_ids])[0].collect{ |id| id.to_i}
            end

            collection_id = params[:target_id].to_i

            collection = Collection.find(collection_id)

            collection.remove_products(product_type_ids, params[:product_tag])

            render :json => {:success => true}
          end
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not delete product types from collection'}
        end
      end

    end # CollectionsController
  end # V1
end # API