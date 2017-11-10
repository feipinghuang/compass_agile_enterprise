module API
  module V1
    class StatusApplicationsController < BaseController

=begin
 @api {get} /api/v1/status_applications
 @apiVersion 1.0.0
 @apiName GetStatusApplications
 @apiGroup StatusApplication
 @apiDescription Get StatusApplications
 
 @apiParam (query) {Integer} [record_id] Id of Record to filter by
 @apiParam (query) {String} [record_type] Type of Record to filter by (WorkEffort, OrderTxn)

 @apiSuccess (200) {Object} get_status_applications_response Response
 @apiSuccess (200) {Boolean} get_status_applications_response.success True if the request was successful.
 @apiSuccess (200) {Number} get_status_applications_response.total_count Total count of records based on any filters applied.
 @apiSuccess (200) {Object[]} get_status_applications_response.status_applications List of StatusApplication records.
 @apiSuccess (200) {Number} get_status_applications_response.status_applications.id Id of StatusApplication.
=end

      def index
        statuses = if params[:record_id].present? && params[:record_type].present?

          record_type = ActionController::Base.helpers.sanitize(params[:record_type]).to_param

          # if the record acts as BizTxnEvent we need to use BizTxnEvent
          record = record_type.constantize.find(params[:record_id])
          if record.respond_to?(:root_txn)
            record_type = 'BizTxnEvent'
            record_id = record.root_txn.id
          else
            record_id = params[:record_id]
          end

          StatusApplication.where('status_application_record_id = ? and status_application_record_type = ?',
                                  record_id,
                                  record_type)
          .includes(:tracked_status_type).order('created_at desc').collect do |status|
            status.to_data_hash
          end

        else
          StatusApplication.all.collect { |status| status.to_data_hash }
        end

        render :json => {:success => true, :status_applications => statuses}
      end

=begin
 @api {get} /api/v1/status_applications/:id
 @apiVersion 1.0.0
 @apiName GetStatusApplication
 @apiGroup StatusApplication
 @apiDescription Get StatusApplication
 
 @apiParam (path) {Integer} [id] Id of StatusApplication

 @apiSuccess (200) {Object} get_status_application_response Response
 @apiSuccess (200) {Boolean} get_status_application_response.success True if the request was successful.
 @apiSuccess (200) {Object[]} get_status_application_response.status_application StatusApplication records
 @apiSuccess (200) {Number} get_status_application_response.status_application.id Id of StatusApplication.
=end

      def show
        status_application = StatusApplication.find(params[:id])

        render :json => {:success => true, :status_application => status_application.to_data_hash}
      end

    end # StatusApplicationsController
  end # V1
end # API
