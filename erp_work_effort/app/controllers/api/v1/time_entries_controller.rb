module Api
  module V1
    class TimeEntriesController < BaseController

      def index
        render :json => {success: true, work_effort_types: WorkEffortType.all.map { |type| type.to_data_hash }}
      end

      def create
        begin
          ActiveRecord::Base.connection.transaction do

            start_at = Time.parse(params[:start_at])
            end_at = Time.parse(params[:end_at])

            time_entry = TimeEntry.create(
                from_datetime: start_at,
                thru_datetime: end_at
            )

            if params[:work_effort_id]
              work_effort = WorkEffort.find(params[:work_effort_id])

              time_entry.work_effort = work_effort
            end

            time_entry.calculate_regular_hours_in_seconds!

            time_sheet = current_user.party.timesheets.current!(current_user.party, RoleType.iid('work_resource'))

            time_sheet.time_entries << time_entry

            render json: {
                       success: true,
                       time_entry: time_entry.to_data_hash,
                       day_total_formatted: time_sheet.day_total_formatted(Date.today),
                       week_total_formatted: time_sheet.total_formatted
                   }

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error creating Time Entry'}
        end
      end

      def show
        work_effort_type = WorkEffortType.find(params[:id])

        render :json => {success: true, work_effort_type: [work_effort_type.to_data_hash]}
      end

    end # WorkEffortTypeController
  end # V1
end # Api