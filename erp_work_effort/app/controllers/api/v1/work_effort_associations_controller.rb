module Api
  module V1
    class WorkEffortAssociationsController < BaseController

      def index
        render :json => {success: true, work_effort_associations: WorkEffortAssociation.all.map { |work_effort| work_effort.to_data_hash }}
      end

      def show
        render :json => {success: true, work_effort_association: WorkEffortAssociation.find(params[:id]).to_data_hash}
      end

      def create
        begin
          ActiveRecord::Base.connection.transaction do

            work_effort_association = WorkEffortAssociation.new
            work_effort_association.work_effort_id_from = params[:work_effort_id_from]
            work_effort_association.work_effort_id_to = params[:work_effort_id_to]
            work_effort_association.work_effort_association_type = WorkEffortAssociationType.where('external_identifier = ?', params[:work_effort_association_type_external_id].to_s).first
            work_effort_association.save!

            render :json => {success: true, work_effort_association: work_effort_association.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error creating Work Effort Association'}
        end
      end

      def update
        begin
          ActiveRecord::Base.connection.transaction do

            work_effort_association = WorkEffortAssociation.find(params[:id])
            work_effort_association.work_effort_id_from = params[:work_effort_id_from]
            work_effort_association.work_effort_id_to = params[:work_effort_id_to]
            work_effort_association.work_effort_association_type = WorkEffortAssociationType.where('external_identifier = ?', params[:work_effort_association_type_external_id].to_s).first
            work_effort_association.save!

            render :json => {success: true, work_effort_association: work_effort_association.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error updating Work Effort Association'}
        end
      end

      def destroy
        work_effort_association = WorkEffortAssociation.find(params[:id])

        begin
          ActiveRecord::Base.connection.transaction do

            render json: {success: work_effort_association.destroy}

          end
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error destroying Work Effort Association'}
        end
      end

    end # WorkEffortAssociationsController
  end # V1
end # Api