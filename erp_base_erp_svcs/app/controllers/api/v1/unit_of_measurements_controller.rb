module API
  module V1
    class UnitOfMeasurementsController < BaseController

=begin

 @api {get} /api/v1/unit_of_measurements Index
 @apiVersion 1.0.0
 @apiName GetUnitOfMeasurements
 @apiGroup UnitOfMeasurement
 @apiDescription Get UnitOfMeasurements

 @apiParam {String} [query] Query to search description by

 @apiSuccess {Boolean} success True if the request was successful
 @apiSuccess {Number} total_count Total count of records based on any filters applied
 @apiSuccess {Array} unit_of_measurements List of UnitOfMeasurement records
 @apiSuccess {Number} unit_of_measurements.id Id of UnitOfMeasurement

=end

      def index
        sort = 'description'
        dir = 'ASC'

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'description'
          dir = sort_hash[:direction] || 'ASC'
        end
        limit = params[:limit] || 25
        start = params[:start] || 0
        statement = UnitOfMeasurement.scope_by_dba_organization(current_user.party.dba_organization)

        if params[:query]
          statement = statement.where(UnitOfMeasurement.arel_table[:description].matches(params[:query] + '%').or(UnitOfMeasurement.arel_table[:internal_identifier].matches(params[:query] + '%')))
        end

        total_count = statement.count

        if params[:id]
          statement = statement.where(id: params[:id])
        end

        if sort and dir
          statement = statement.order("#{sort} #{dir}")
        end

        if start and limit
          statement = statement.offset(start).limit(limit)
        end

        render json: {total_count: total_count,unit_of_measurements: statement.all.collect(&:to_data_hash)}
      end

    end # UnitOfMeasurementsController
  end # V1
end # API
