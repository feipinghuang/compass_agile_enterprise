module API
  module V1
    class GeoZonesController < BaseController

      skip_before_filter :require_login, :only => :index

=begin

 @api {get} /api/v1/geo_zones
 @apiVersion 1.0.0
 @apiName GetGeoZones
 @apiGroup GeoZone
 @apiDescription Get GeoZones

 @apiSuccess (200) {Object} get_get_zones_response Response
 @apiSuccess (200) {Boolean} get_get_zones_response.success True if the request was successful
 @apiSuccess (200) {Number} get_get_zones_response.total_count Total count of records based on any filters applied
 @apiSuccess (200) {Object[]} get_get_zones_response.geo_zones GeoZone records
 @apiSuccess (200) {Number} get_get_zones_response.geo_zones.id Id of GeoZone

=end

      def index
        GeoZone.include_root_in_json = false

        if params[:geo_country_iso_code_2].present?
          geo_country = GeoCountry.find_by_iso_code_2(params[:geo_country_iso_code_2])
          if geo_country
            render json: {success: true, geo_zones: GeoZone.where('geo_country_id = ?', geo_country.id).all}
          else
            render json: {success: false, message: 'Invalid Geo Country'}
          end

        else
          render json: {success: true, geo_zones: GeoZone.all}
        end
      end

    end # GeoZonesController
  end # V1
end # API
