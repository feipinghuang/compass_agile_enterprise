module API
  module V1
    class InventoryTxnsController < ActionController::Base

=begin

  @api {get} /api/v1/inventory_txns Index
  @apiVersion 1.0.0
  @apiName GetInventorytxns
  @apiGroup InventoryTxns
  @apiDescription Get Inventory txns

  @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
  @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25
  @apiParam (query) {String} [query_filter] JSON string of data to filter by
  @apiParam (query) {String} [query] String to query by
  
  @apiSuccess (200) {Object} get_inventory_txns_response Response
  @apiSuccess (200) {Boolean} get_inventory_txns_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_inventory_txns_response.inventory_txns InventoryTxn records
  @apiSuccess (200) {Number} get_inventory_txns_response.inventory_txns.id Id of InventoryTxn

=end

      def index
        sort = nil
        dir = nil
        limit = nil
        start = nil

        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)

        dir = sort_hash[:direction] || 'ASC'

        limit = params[:limit] || 25
        start = params[:start] || 0

        query_filter = params[:query_filter].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:query_filter]))

        if params[:query]
          query_filter[:keyword] = params[:query].strip
        end

        # hook method to apply any scopes passed via parameters to this api
        inventory_txns = InventoryTxn.apply_filters(query_filter)

        #inventory_txns = inventory_txns.by_tenant(current_user.party.dba_organization)

        if params[:id]
          inventory_txns = inventory_txns.where(id: params[:id])
        end

        if sort and dir
          inventory_txns = inventory_txns.order("#{sort} #{dir}")
        end

        total_count = inventory_txns.count

        if start and limit
          inventory_txns = inventory_txns.offset(start).limit(limit)
        end

        render :json => {success: true, total_count: total_count, inventory_txns: inventory_txns.collect(&:to_data_hash)}
      end

=begin

 @api {post} /api/v1/inventory_txns
 @apiVersion 1.0.0
 @apiName CreateInventoryTxn
 @apiGroup InventoryTxn
 @apiDescription Create Inventory Txn

 @apiParam (body) {Integer} quantity Number available

 @apiSuccess (200) {Object} create_inventory_txn_response Response.
 @apiSuccess (200) {Boolean} create_inventory_txn_response.success True if the request was successful
 @apiSuccess (200) {Object} create_inventory_txn_response.inventory_txn InventoryTxn record
 @apiSuccess (200) {Number} create_inventory_txn_response.inventory_txn.id Id of InventoryTxn

=end

      def create
        begin
          ActiveRecord::Base.transaction do

            # TODO: temp test code
            inventory_entry = InventoryEntry.first
            fixed_asset = FixedAsset.first


            inventory_txn = InventoryTxn.new
            inventory_txn.fixed_asset_id = fixed_asset.id
            inventory_txn.inventory_entry_id = inventory_entry.id
            inventory_txn.quantity = params[:quantity].to_i
            inventory_txn.acutal_quantity = params[:quantity].to_i
            inventory_txn.is_sell = false
            inventory_txn.applied = false
            inventory_txn.applied_at = Time.now
            #inventory_txn.created_by_id = current_user.party.id

            inventory_txn.save!

            #inventory_txn.set_tenant!(current_user.party.dba_organization)

            render :json => {success: true,
                             inventory_txn: inventory_txn.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not create InventoryTxn'}
        end
      end

=begin

 @api {get} /api/v1/inventory_txns/:id
 @apiVersion 1.0.0
 @apiName GetInventoryTxn
 @apiGroup InventoryTxn
 @apiDescription Get Inventory Txn

 @apiParam (query) {Integer} id Id of InventoryTxn

 @apiSuccess (200) {Object} get_inventory_txn_response Response.
 @apiSuccess (200) {Boolean} get_inventory_txn_response.success True if the request was successful
 @apiSuccess (200) {Object} get_inventory_txn_response.inventory_txn InventoryTxn record
 @apiSuccess (200) {Number} get_inventory_txn_response.inventory_txn.id Id of InventoryTxn

=end

      def show
        inventory_txn = InventoryTxn.find(params[:id])

        render json: {success: true,
                      inventory_txn: inventory_txn.to_data_hash}
      end


=begin

 @api {put} /api/v1/inventory_txns/:id
 @apiVersion 1.0.0
 @apiName UpdateInventoryTxn
 @apiGroup InventoryTxn
 @apiDescription Update Inventory Txn

 @apiParam (query) {Integer} id InventoryTxn Id
 @apiParam (body) {Integer} [quantity] Number available

 @apiSuccess (200) {Object} update_inventory_txn_response Response.
 @apiSuccess (200) {Boolean} update_inventory_txn_response.success True if the request was successful
 @apiSuccess (200) {Object} update_inventory_txn_response.inventory_txn InventoryTxn record
 @apiSuccess (200) {Number} update_inventory_txn_response.inventory_txn.id Id of InventoryTxn

=end

      def update
        begin
          ActiveRecord::Base.transaction do
            inventory_txn = InventoryTxn.find(params[:id])

            if params[:quantity].present?
              inventory_txn.quantity = params[:quantity].to_i
            end

            inventory_txn.save!

            render :json => {success: true,
                             inventory_txn: inventory_txn.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not update InventoryTxn'}
        end
      end



=begin

 @api {delete} /api/v1/inventory_txns/:id
 @apiVersion 1.0.0
 @apiName DeleteInventoryTxn
 @apiGroup InventoryTxn
 @apiDescription Delete Inventory Txn

 @apiParam (param) {Integer} id Id of record to delete

 @apiSuccess (200) {Object} delete_inventory_entry_response Response.
 @apiSuccess (200) {Boolean} delete_inventory_entry_response.success True if the request was successful

=end

      def destroy
        InventoryTxn.find(params[:id]).destroy

        render json: {:success => true}
      end


      
      

=begin

  @api {put} /api/v1/inventory_txns/:id/apply 
  @apiVersion 1.0.0
  @apiName ApplyInventoryTxn
  @apiGroup InventoryTxn
  @apiDescription Apply an InventoryTxn

  @apiParam (query) {Integer} id InventoryTxn Id
  
  @apiSuccess (200) {Object} apply_inventory_txn_response Response
  @apiSuccess (200) {Boolean} apply_inventory_txn_response.success True if the request was successful

=end

      def apply
        begin
          ActiveRecord::Base.transaction do
            inventory_txn = InventoryTxn.find(params[:id])

            inventory_txn.apply!

            render :json => {success: true}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not apply'}
        end
      end

=begin

  @api {put} /api/v1/inventory_txns/:id/unapply 
  @apiVersion 1.0.0
  @apiName UnapplyInventoryTxn
  @apiGroup InventoryTxn
  @apiDescription Unapply an InventoryTxn

  @apiParam (query) {Integer} id InventoryTxn Id
  
  @apiSuccess (200) {Object} unapply_inventory_txn_response Response
  @apiSuccess (200) {Boolean} unapply_inventory_txn_response.success True if the request was successful

=end

      def unapply
        begin
          ActiveRecord::Base.transaction do
            inventory_txn = InventoryTxn.find(params[:id])

            inventory_txn.unapply!

            render :json => {success: true}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not unapply'}
        end
      end

    end # InventoryTxnsController
  end # V1
end # API
