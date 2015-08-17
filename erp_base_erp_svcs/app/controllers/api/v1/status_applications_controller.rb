module Api
  module V1
    class StatusApplicationsController < BaseController

      def index
        statuses = if params[:record_id].present? && params[:record_type].present?

                     StatusApplication.where('status_application_record_id = ? and status_application_record_type = ?',
                                             params[:record_id],
                                             params[:record_type])
                         .includes(:tracked_status_type).order('created_at desc').collect do |status|
                       status.to_data_hash
                     end

                   else
                     StatusApplication.all.collect{|status| status.to_data_hash}
                   end

        render :json => {:success => true, :status_applications => statuses}
      end

      def show
        status_application = StatusApplication.find(params[:id])

        render :json => {:success => true, :status_application => status_application.to_data_hash}
      end

    end # StatusApplicationsController
  end # V1
end # Api