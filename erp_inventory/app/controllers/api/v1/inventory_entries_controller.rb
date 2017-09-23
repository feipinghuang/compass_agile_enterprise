module API
  module V1
    class InventoryEntriesController < BaseController

=begin

  @api {get} /api/v1/inventory_entries Index
  @apiVersion 1.0.0
  @apiName GetInventoryEntries
  @apiGroup InventoryEntry
  @apiDescription Get Inventory Entries

  @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
  @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25
  @apiParam (query) {String} [query_filter] JSON string of data to filter by
  @apiParam (query) {String} [query] String to query by
  
  @apiSuccess (200) {Object} get_inventory_entries_response Response
  @apiSuccess (200) {Boolean} get_inventory_entries_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_inventory_entries_response.inventory_entries InventoryEntry records
  @apiSuccess (200) {Number} get_inventory_entries_response.inventory_entries.id Id of InventoryEntry

=end

      def index
        sort = nil
        dir = nil
        limit = nil
        start = nil

        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)

        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'

        limit = params[:limit].blank? ? nil : params[:limit]
        start = params[:start].blank? ? nil : params[:start]

        query_filter = params[:query_filter].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:query_filter]))

        if params[:query]
          query_filter[:keyword] = params[:query].strip
        end

        # hook method to apply any scopes passed via parameters to this api
        inventory_entries = InventoryEntry.apply_filters(query_filter)

        inventory_entries = inventory_entries.by_tenant(current_user.party.dba_organization)

        if params[:id]
          inventory_entries = inventory_entries.where(id: params[:id])
        end

        if sort and dir
          inventory_entries = inventory_entries.order("#{sort} #{dir}")
        end

        total_count = inventory_entries.count

        if start and limit
          inventory_entries = inventory_entries.offset(start).limit(limit)
        end

        render :json => {success: true, total_count: total_count, inventory_entries: inventory_entries.collect(&:to_data_hash)}
      end

=begin

 @api {get} /api/v1/inventory_entries/:id
 @apiVersion 1.0.0
 @apiName GetInventoryEntry
 @apiGroup InventoryEntry
 @apiDescription Get Inventory Entry

 @apiParam (query) {Integer} id Id of InventoryEntry

 @apiSuccess (200) {Object} get_inventory_entry_response Response.
 @apiSuccess (200) {Boolean} get_inventory_entry_response.success True if the request was successful
 @apiSuccess (200) {Object} get_inventory_entry_response.inventory_entry InventoryEntry record
 @apiSuccess (200) {Number} get_inventory_entry_response.inventory_entry.id Id of InventoryEntry

=end

      def show
        inventory_entry = InventoryEntry.find(params[:id])

        render json: {success: true,
                      inventory_entry: inventory_entry.to_data_hash}
      end

=begin

 @api {post} /api/v1/inventory_entries
 @apiVersion 1.0.0
 @apiName CreateInventoryEntry
 @apiGroup InventoryEntry
 @apiDescription Create Inventory Entry

 @apiParam (body) {String} description Description
 @apiParam (body) {String} sku SKU to set
 @apiParam (body) {String} external_identifier External Identifier to set
 @apiParam (body) {String} external_id_source External Id Source to set
 @apiParam (body) {String} product_type Internal Identifier of ProductType
 @apiParam (body) {Integer} number_available Number available
 @apiParam (body) {Integer} number_in_stock Number in stock
 @apiParam (body) {Integer} number_sold Number sold
 @apiParam (body) {String} unit_of_measurement Internal Identifier of Unit Of Measurement

 @apiSuccess (200) {Object} create_inventory_entry_response Response.
 @apiSuccess (200) {Boolean} create_inventory_entry_response.success True if the request was successful
 @apiSuccess (200) {Object} create_inventory_entry_response.inventory_entry InventoryEntry record
 @apiSuccess (200) {Number} create_inventory_entry_response.inventory_entry.id Id of InventoryEntry

=end

      def create
        begin
          ActiveRecord::Base.transaction do
            inventory_entry = InventoryEntry.new
            inventory_entry.description = params[:description]
            inventory_entry.sku = params[:sku]
            inventory_entry.unit_of_measurement_id = UnitOfMeasurement.iid(params[:unit_of_measurement])
            inventory_entry.product_type = ProductType.find_by_internal_identifier(params[:product_type])
            inventory_entry.external_id_source = params[:external_id_source]
            inventory_entry.external_identifier = params[:external_identifier]
            inventory_entry.number_in_stock = params[:number_in_stock]
            inventory_entry.number_sold = params[:number_sold]
            inventory_entry.number_available = params[:number_available]

            inventory_entry.save!

            inventory_entry.set_tenant!(current_user.party.dba_organization)

            render :json => {success: true,
                             inventory_entry: inventory_entry.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not create InventoryEntry'}
        end
      end

=begin

 @api {put} /api/v1/inventory_entries/:id
 @apiVersion 1.0.0
 @apiName UpdateInventoryEntry
 @apiGroup InventoryEntry
 @apiDescription Update Inventory Entry
  
 @apiParam (query) {Integer} id InventoryEntry Id
 @apiParam (body) {String} [description] Description
 @apiParam (body) {String} [sku] SKU to set
 @apiParam (body) {String} [external_identifier] External Identifier to set
 @apiParam (body) {String} [external_id_source] External Id Source to set
 @apiParam (body) {String} [product_type] Internal Identifier of ProductType
 @apiParam (body) {Integer} [number_available] Number available
 @apiParam (body) {Integer} [number_in_stock] Number in stock
 @apiParam (body) {Integer} [number_sold] Number sold
 @apiParam (body) {String} [unit_of_measurement] Internal Identifier of Unit Of Measurement

 @apiSuccess (200) {Object} update_inventory_entry_response Response.
 @apiSuccess (200) {Boolean} update_inventory_entry_response.success True if the request was successful
 @apiSuccess (200) {Object} update_inventory_entry_response.inventory_entry InventoryEntry record
 @apiSuccess (200) {Number} update_inventory_entry_response.inventory_entry.id Id of InventoryEntry

=end

      def update
        begin
          ActiveRecord::Base.transaction do
            inventory_entry = InventoryEntry.find(params[:id])

            if params[:description].present?
              inventory_entry.description = params[:description]
            end

            if params[:sku].present?
              inventory_entry.sku = params[:sku]
            end

            if params[:unit_of_measurement].present?
              inventory_entry.unit_of_measurement_id = UnitOfMeasurement.iid(params[:unit_of_measurement])
            end

            if params[:product_type].present?
              inventory_entry.product_type = ProductType.find_by_internal_identifier(params[:product_type])
            end

            if params[:descripexternal_id_sourcetion].present?
              inventory_entry.external_id_source = params[:external_id_source]
            end

            if params[:external_identifier].present?
              inventory_entry.external_identifier = params[:external_identifier]
            end

            if params[:number_in_stock].present?
              inventory_entry.number_in_stock = params[:number_in_stock]
            end

            if params[:number_sold].present?
              inventory_entry.number_sold = params[:number_sold]
            end

            if params[:number_available].present?
              inventory_entry.number_available = params[:number_available]
            end

            inventory_entry.save!

            render :json => {success: true,
                             inventory_entry: inventory_entry.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not update InventoryEntry'}
        end
      end

=begin

 @api {post} /api/v1/inventory_entries/:id/add_party_with_role
 @apiVersion 1.0.0
 @apiName AddPartyWithRole
 @apiGroup InventoryEntry
 @apiDescription Add Party with a Role to an InventoryEntry
  
 @apiParam (query) {Integer} id InventoryEntry Id
 @apiParam (body) {integer} party_id Id of Party
 @apiParam (body) {String} role_types Comma seperated list of RoleType Internal Identifiers

 @apiSuccess (200) {Object} inventory_entry_add_party_with_role_response Response.
 @apiSuccess (200) {Boolean} inventory_entry_add_party_with_role_response.success True if the request was successful

=end

      def add_party_with_role
        begin
          ActiveRecord::Base.transaction do
            inventory_entry = InventoryEntry.find(params[:id])
            party = Party.find(params[:party_id])

            params[:role_types].split(',').each do |role_type|
              inventory_entry.add_party_with_role(party, RoleType.iid(role_type))
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

          render json: {success: false, message: 'Could not add Party with Role'}
        end
      end

=begin

 @api {delete} /api/v1/inventory_entries/:id
 @apiVersion 1.0.0
 @apiName DeleteInventoryEntry
 @apiGroup InventoryEntry
 @apiDescription Delete Inventory Entry

 @apiParam (param) {Integer} id Id of record to delete 

 @apiSuccess (200) {Object} delete_inventory_entry_response Response.
 @apiSuccess (200) {Boolean} delete_inventory_entry_response.success True if the request was successful

=end

      def destroy
        InventoryEntry.find(params[:id]).destroy

        render json: {:success => true}
      end

    end # InventoryEntriesController
  end # V1
end # API
