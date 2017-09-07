module API
  module V1
    class InventoryEntryLocationsController < BaseController

=begin

  @api {get} /api/v1/inventory_entry_locations Index
  @apiVersion 1.0.0
  @apiName GetInventoryEntryLocations
  @apiGroup InventoryEntryLocation
  @apiDescription Get Inventory Entry Locations

  @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
  @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25
  @apiParam (query) {Integer} [inventory_entry_id] InventoryEntry Id
  
  @apiSuccess (200) {Object} get_inventory_entry_locations_response Response
  @apiSuccess (200) {Boolean} get_inventory_entry_locations_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_inventory_entry_locations_response.inventory_entry_locations InventoryEntryLocation records
  @apiSuccess (200) {Number} get_inventory_entry_locations_response.inventory_entry_locations.id Id of InventoryEntryLocation

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

        inventory_entry_locations = IventoryEntryLocation

        if params[:inventory_entry_id]
          inventory_entry_locations = inventory_entry_locations.where(inventory_entry_id: params[:inventory_entry_id])
        end

        if sort && dir
          inventory_entry_locations = inventory_entry_locations.order("#{sort} #{dir}")
        end

        total_count = inventory_entry_locations.count

        if start && limit
          inventory_entry_locations = inventory_entry_locations.offset(start).limit(limit)
        end

        render :json => {success: true,
                         total_count: total_count,
                         inventory_entry_locations: inventory_entry_locations.collect(&:to_data_hash)}
      end

=begin

 @api {get} /api/v1/inventory_entry_locations/:id
 @apiVersion 1.0.0
 @apiName GetInventoryEntryLocation
 @apiGroup InventoryEntryLocation
 @apiDescription Get Inventory Entry Location

 @apiParam (query) {Integer} id Id of InventoryEntryLocation

 @apiSuccess (200) {Object} get_inventory_entry_locations_response Response.
 @apiSuccess (200) {Boolean} get_inventory_entry_locations_response.success True if the request was successful
 @apiSuccess (200) {Object} get_inventory_entry_locations_response.inventory_entry_location InventoryEntry record
 @apiSuccess (200) {Number} get_inventory_entry_locations_response.inventory_entry_location.id Id of InventoryEntry

=end

      def show
        inventory_entry_location = InventoryEntryLocation.find(params[:id])

        render json: {success: true,
                      inventory_entry_location: inventory_entry_location.to_data_hash}
      end

=begin

 @api {post} /api/v1/inventory_entry_locations
 @apiVersion 1.0.0
 @apiName CreateInventoryEntryLocation
 @apiGroup InventoryEntryLocation
 @apiDescription Create Inventory Entry Location

 @apiParam (body) {Integer} inventory_entry_id Id of InventoryEntry
 @apiParam (body) {Integer} facility_id Id of Facility

 @apiSuccess (200) {Object} create_inventory_entry_location_response Response.
 @apiSuccess (200) {Boolean} create_inventory_entry_location_response.success True if the request was successful
 @apiSuccess (200) {Object} create_inventory_entry_location_response.inventory_entry_location InventoryEntryLocation record
 @apiSuccess (200) {Number} create_inventory_entry_location_response.inventory_entry_location.id Id of InventoryEntryLocation

=end

      def create
        begin
          ActiveRecord::Base.transaction do
            inventory_entry_location = InventoryEntryLocation.new(facility_id: params[:facility_id],
                                                                  inventory_entry_id: params[:inventory_entry_id])

            inventory_entry_location.save!

            render :json => {success: true,
                             inventory_entry_location: inventory_entry_location.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not create InventoryEntryLocation'}
        end
      end

=begin

 @api {put} /api/v1/inventory_entry_locations/:id
 @apiVersion 1.0.0
 @apiName UpdateInventoryEntryLocation
 @apiGroup InventoryEntryLocation
 @apiDescription Update Inventory Entry Location
  
 @apiParam (query) {Integer} id InventoryEntryLocation Id
 @apiParam (body) {Integer} [inventory_entry_id] Id of InventoryEntry
 @apiParam (body) {Integer} [facility_id] Id of Facility

 @apiSuccess (200) {Object} update_inventory_entry_location_response Response.
 @apiSuccess (200) {Boolean} update_inventory_entry_location_response.success True if the request was successful
 @apiSuccess (200) {Object} update_inventory_entry_location_response.inventory_entry InventoryEntryLocation record
 @apiSuccess (200) {Number} update_inventory_entry_location_response.inventory_entry.id Id of InventoryEntryLocation

=end

      def update
        begin
          ActiveRecord::Base.transaction do
            inventory_entry_location = InventoryEntryLocation.find(params[:id])

            if params[:inventory_entry_id].present?
              inventory_entry_location.inventory_entry_id = params[:inventory_entry_id]
            end

            if params[:facility_id].present?
              inventory_entry_location.facility_id = params[:facility_id]
            end

            inventory_entry_location.save!

            render :json => {success: true,
                             inventory_entry_location: inventory_entry_location.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not update InventoryEntryLocation'}
        end
      end

=begin

 @api {delete} /api/v1/inventory_entry_locations/:id
 @apiVersion 1.0.0
 @apiName DeleteInventoryEntryLocation
 @apiGroup InventoryEntryLocation
 @apiDescription Delete Inventory Entry Location

 @apiParam (param) {Integer} id Id of record to delete 

 @apiSuccess (200) {Object} delete_inventory_entry_location_response Response.
 @apiSuccess (200) {Boolean} delete_inventory_entry_location_response.success True if the request was successful

=end

      def destroy
        InventoryEntryLocation.find(params[:id]).destroy

        render json: {:success => true}
      end

    end # InventoryEntryLocationsController
  end # V1
end # API
