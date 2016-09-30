module Api
  module V1
    class InventoryEntriesController < BaseController

=begin

  @api {get} /api/v1/inventory_entries Index
  @apiVersion 1.0.0
  @apiName GetInventoryEntries
  @apiGroup InventoryEntry

  @apiSuccess {Boolean} success True if the request was successful
  @apiSuccess {Array} inventory_entries List of InventoryEntry records
  @apiSuccess {Number} inventory_entries.id Id of InventoryEntry

=end

      def index
        sort = nil
        dir = nil
        limit = nil
        start = nil

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'id'
          dir = sort_hash[:direction] || 'ASC'
          limit = params[:limit] || 25
          start = params[:start] || 0
        end

        inventory_entries = InventoryEntry
        inventory_entries = inventory_entries.by_tenant(current_user.party.dba_organization)

        if sort and dir
          inventory_entries = inventory_entries.order("#{sort} #{dir}")
        end

        total_count = inventory_entries.count

        if start and limit
          inventory_entries = inventory_entries.offset(start).limit(limit)
        end

        render :json => {success: true, total_count: total_count, inventory_entries: inventory_entries.collect(&:to_data_hash)}
      end

    end # InventoryEntriesController
  end # V1
end # Api
