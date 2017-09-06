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

        collections = collections.order('description')

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
            collection.description = params[:description]
            collection.internal_identifier = params[:description].to_iid


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
            collection = Collection.find(params[:id].to_i)
            collection.description = params[:description]
            collection.internal_identifier = params[:description].to_iid
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

    end # CollectionsController
  end # V1
end # API