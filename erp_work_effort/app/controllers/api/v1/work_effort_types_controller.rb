module Api
  module V1
    class WorkEffortTypesController < BaseController

=begin

 @api {get} /api/v1/work_effort_types Index
 @apiVersion 1.0.0
 @apiName GetWorkEffortTypes
 @apiGroup WorkEffortType

 @apiSuccess {Boolean} success True if the request was successful
 @apiSuccess {Array} work_effort_types List of WorkEffortTypes
 @apiSuccess {Number} work_effort_types.id Id of WorkEffortType
 @apiSuccess {String} work_effort_types.description Description of WorkEffortType
 @apiSuccess {String} work_effort_types.internal_identifier Internal Identifier of WorkEffortType
 @apiSuccess {DateTime} work_effort_types.created_at When the WorkEffortType was created
 @apiSuccess {DateTime} work_effort_types.updated_at When the WorkEffortType was updated

=end

      def index
        render :json => {success: true, work_effort_types:  WorkEffortType.all.map { |type| type.to_data_hash }}
      end

=begin

 @api {get} /api/v1/work_effort_types/:id Show
 @apiVersion 1.0.0
 @apiName ShowWorkEffortTypes
 @apiGroup WorkEffortType

 @apiSuccess {Boolean} success True if the request was successful
 @apiSuccess {Array} work_effort_type WorkEffortType
 @apiSuccess {Number} work_effort_type.id Id of WorkEffortType
 @apiSuccess {String} work_effort_type.description Description of WorkEffortType
 @apiSuccess {String} work_effort_type.internal_identifier Internal Identifier of WorkEffortType
 @apiSuccess {DateTime} work_effort_type.created_at When the WorkEffortType was created
 @apiSuccess {DateTime} work_effort_type.updated_at When the WorkEffortType was updated

=end

      def show
        work_effort_type = WorkEffortType.find(params[:id])

        render :json => {success: true, work_effort_type: [work_effort_type.to_data_hash]}
      end

    end # WorkEffortTypeController
  end # V1
end # Api