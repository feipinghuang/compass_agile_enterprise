module Api
  module V1
    class WorkEffortsController < BaseController

      def index

        work_efforts = WorkEffort.where("parent_id is null").order("created_at ASC")

        render :json => {success: true, work_efforts: work_efforts.map { |work_effort| work_effort.to_data_hash }}

      end

      def show
        work_effort = WorkEffort.find(params[:id])

        respond_to do |format|
          # if a tree format was requested then respond with the children of this WorkEffort
          format.tree do
            render :json => {success: true, work_efforts: work_effort.children.collect { |child| child.to_data_hash }}
          end

          # if a json format was requested then respond with the WorkEffort in json format
          format.json do
            render :json => {success: true, work_effort: work_effort.to_data_hash}
          end
        end
      end

      def create
        begin
          ActiveRecord::Base.connection.transaction do
            work_efforts = []

            if params[:work_efforts]
              params[:work_efforts].each do |work_effort_data|
                work_efforts << create_work_effort(work_effort_data)
              end
            else
              work_efforts << create_work_effort(params)
            end

            render :json => {success: true, work_efforts: work_efforts.map { |work_effort| work_effort.to_data_hash }}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error creating Work Effort'}
        end
      end

      def update
        begin
          ActiveRecord::Base.connection.transaction do
            work_efforts = []

            if params[:work_efforts]
              params[:work_efforts].each do |work_effort_data|
                work_efforts << update_work_effort(work_effort_data)
              end
            else
              work_efforts << update_work_effort(params)
            end

            render :json => {success: true, work_efforts: work_efforts.map { |work_effort| work_effort.to_data_hash }}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error updating Work Effort'}
        end
      end

      def destroy
        work_effort = WorkEffort.find(params[:id])

        begin
          ActiveRecord::Base.connection.transaction do

            render json: {success: work_effort.destroy}

          end
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error creating Work Effort'}
        end
      end

      protected

      def create_work_effort(data)
        work_effort = WorkEffort.new
        work_effort.description = data[:description].strip

        if data[:started_at].present?
          work_effort.started_at = Date.parse(data[:started_at])
        end

        if data[:finished_at].present?
          work_effort.finished_at = Date.parse(data[:finished_at])
        end

        work_effort.save!

        if data[:parent_id].present? and data[:parent_id] != 0
          parent = WorkEffort.find(data[:parent_id])
          work_effort.move_to_child_of(parent)
          work_effort.reload
        end

        work_effort
      end

      def update_work_effort(data)
        work_effort = WorkEffort.find(data[:server_id])
        work_effort.description = data[:description].strip

        if data[:started_at].present?
          work_effort.started_at = Date.parse(data[:started_at])
        end

        if data[:finished_at].present?
          work_effort.finished_at = Date.parse(data[:finished_at])
        end

        work_effort.save!

        if data[:parent_id].present? and data[:parent_id] != 0
          parent = WorkEffort.find(data[:parent_id])
          work_effort.move_to_child_of(parent)
          work_effort.reload
        end

        work_effort
      end

    end # WorkEffortsController
  end # V1
end # Api