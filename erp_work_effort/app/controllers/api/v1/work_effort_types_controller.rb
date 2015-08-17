module Api
  module V1
    class WorkEffortTypesController < BaseController

      def index
        render :json => {success: true, work_effort_types:  WorkEffortType.all.map { |type| type.to_data_hash }}
      end

      def show
        work_effort_type = WorkEffortType.find(params[:id])

        render :json => {success: true, work_effort_type: [work_effort_type.to_data_hash]}
      end

    end # WorkEffortTypeController
  end # V1
end # Api