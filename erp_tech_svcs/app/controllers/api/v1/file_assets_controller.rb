module Api
  module V1
    class FileAssetsController < BaseController

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0
        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        # apply filters
        file_assets = FileAsset.apply_filters(query_filter)

        # if no file asset holder was passed we need to scope by dba_organization
        if !query_filter[:file_asset_holder_type].present? && !query_filter[:file_asset_holder_id].present?
          file_assets = file_assets.scope_by_dba_org(current_user.party.dba_organization)
        end

        total_count = file_assets.count
        file_assets = file_assets.limit(limit).offset(start)
        file_assets.order("#{sort} #{dir}")

        render json: {success: true,
                      total_count: total_count,
                      file_assets: file_assets.collect { |file| file.to_data_hash }}
      end

      def destroy
        file_asset = FileAsset.find(params[:id])

        file_asset.destroy

        render json: {success: true}
      end

    end # FileAssetsController
  end # V1
end # Api