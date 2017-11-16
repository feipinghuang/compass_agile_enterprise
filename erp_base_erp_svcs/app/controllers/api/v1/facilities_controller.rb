module API
  module V1
    class FacilitiesController < BaseController

=begin

 @api {get} /api/v1/facilities
 @apiVersion 1.0.0
 @apiName GetFacilities
 @apiGroup Facility
 @apiDescription Get Facilities

 @apiSuccess (200) {Object} get_facilities_response Response
 @apiSuccess (200) {Boolean} get_facilities_response.success True if the request was successful
 @apiSuccess (200) {Number} get_facilities_response.total_count Total count of records based on any filters applied
 @apiSuccess (200) {Object[]} get_facilities_response.facilities Facility records
 @apiSuccess (200) {Number} get_facilities_response.facilities.id Id of Facility

=end

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'

        facilities = Facility.by_tenant(current_user.party.dba_organization)

        total_count = facilities.count

        if params[:limit].present?
          facilities = facilities.limit(params[:limit])
        end

        if params[:start].present?
          facilities = facilities.offset(params[:start])
        end

        facilities = facilities.uniq.order(ActiveRecord::Base.sanitize_order_params(sort, dir))

        render :json => {success: true, total_count: total_count, facilities: facilities.all.collect(&:to_data_hash)}
      end

    end # FacilitiesController
  end # V1
end # API
