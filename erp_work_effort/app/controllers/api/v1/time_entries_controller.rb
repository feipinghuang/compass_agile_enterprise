 module Api
  module V1
    class TimeEntriesController < BaseController

      def create
        begin
          ActiveRecord::Base.connection.transaction do
            party = current_user.party

            time_entry = TimeEntry.new(
                manual_entry: true
            )

            if params[:from_datetime]
              time_entry.from_datetime = Time.strptime(params[:from_datetime], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            end

            if params[:thru_datetime]
              time_entry.from_datetime = Time.strptime(params[:thru_datetime], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            end

            if params[:comment]
              time_entry.comment = params[:comment].strip
            end

            if params[:regular_hours_in_seconds]
              time_entry.regular_hours_in_seconds = params[:regular_hours_in_seconds].to_i
            end

            if params[:overtime_hours_in_seconds]
              time_entry.overtime_hours_in_seconds = params[:regular_hours_in_seconds].to_i
            end

            if params[:work_effort_id]
              time_entry.work_effort = params[:work_effort_id]
            end

            # if a timesheet id is passed assoicate to that timesheet if not associate to
            # the current user's timesheet
            if params[:timesheet_id]
              time_entry.timesheet_id = params[:timesheet_id]
            else
              time_sheet = party.timesheets.current!(current_user.party, RoleType.iid('work_resource'))
              time_entry.timesheet_id = time_sheet.id
            end

            render json: {
                       success: true,
                       time_entry: time_entry.to_data_hash,
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

      def update
        begin
          ActiveRecord::Base.connection.transaction do

            time_entry = TimeEntry.find(params[:id])

            if params[:from_datetime]
              time_entry.from_datetime = Time.strptime(params[:from_datetime], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            end

            if params[:thru_datetime]
              time_entry.from_datetime = Time.strptime(params[:thru_datetime], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            end

            if params[:comment]
              time_entry.comment = params[:comment].strip
            end

            if params[:regular_hours_in_seconds]
              time_entry.regular_hours_in_seconds = params[:regular_hours_in_seconds].to_i
            end

            if params[:overtime_hours_in_seconds]
              time_entry.overtime_hours_in_seconds = params[:regular_hours_in_seconds].to_i
            end

            # update to manual entry
            time_entry.manual_entry = true

            render json: {
                       success: time_entry.save!,
                       time_entry: time_entry.to_data_hash,
                   }

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error updating Time Entry'}
        end
      end

      def show
        time_entry = TimeEntry.find(params[:id])

        render :json => {success: true, time_entry: time_entry.to_data_hash}
      end

      # start TimeEntry by setting the from_datetime but not the thru_datetime
      # if there is already an open time_entry do not let another one be started
      # It is assumed that a TimeEntry is always logged against a work effort so
      # a WorkEffort id should be passed.
      #
      def start
        begin
          ActiveRecord::Base.connection.transaction do

            time_helper = ErpBaseErpSvcs::Helpers::Time::Client.new(params[:client_utc_offset])
            party = current_user.party
            work_effort = WorkEffort.find(params[:work_effort_id])

            # check for an open TimeEntry
            open_time_entry = party.open_time_entry

            # if there is an open TimeEntry stop it and start a new one
            if open_time_entry
              open_time_entry.thru_datetime = time_helper.in_client_time(Time.now)

              open_time_entry.calculate_regular_hours_in_seconds!
            end

            time_entry = TimeEntry.create(
                from_datetime: Time.strptime(params[:start_at], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            )

            time_entry.work_effort = work_effort

            # associate to a timesheet
            time_sheet = party.timesheets.current!(RoleType.iid('work_resource'))
            time_sheet.time_entries << time_entry

            # update task statuses
            time_entry.update_task_status('task_status_in_progress')
            time_entry.update_task_assignment_status('task_resource_status_in_progress')

            render json: {
                       success: true,
                       time_entry: time_entry.to_data_hash,
                   }
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error starting Time Entry'}
        end
      end

      # stop TimeEntry by setting the thru_datetime and calculating the hours in seconds
      # it returns the TimeEntry record as well as formatted totals for the day and week
      #
      def stop
        begin
          ActiveRecord::Base.connection.transaction do
            party = current_user.party
            work_effort = WorkEffort.find(params[:work_effort_id])
            time_entry = TimeEntry.find(params[:id])

            time_entry.thru_datetime = Time.strptime(params[:end_at], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            time_entry.comment = params[:comment].present? ? params[:comment].strip : nil

            time_entry.calculate_regular_hours_in_seconds!

            result = {
                success: true,
                time_entry: time_entry.to_data_hash,
            }

            time_helper = ErpBaseErpSvcs::Helpers::Time::Client.new(params[:client_utc_offset])

            result[:day_total_formatted] = TimeEntry.total_formatted(work_effort: work_effort,
                                                                     party: party,
                                                                     start: time_helper.beginning_of_day,
                                                                     end: time_helper.end_of_day
            )
            result[:week_total_formatted] = TimeEntry.total_formatted(work_effort: work_effort,
                                                                      party: party,
                                                                      start: time_helper.beginning_of_week,
                                                                      end: time_helper.end_of_week
            )

            render json: result
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error stopping Time Entry'}
        end
      end

      # if a work effort id is passed get the last open time_entry for that work_effort
      # for the current user if there are no open time entries then return only the totals
      #
      def open
        if params[:work_effort_id]
          work_effort = WorkEffort.find(params[:work_effort_id])
          party = current_user.party

          open_time_entry = work_effort.time_entries.scope_by_party(current_user.party).open.first
          time_helper = ErpBaseErpSvcs::Helpers::Time::Client.new(params[:client_utc_offset])

          render :json => {success: true,
                           time_entry: open_time_entry.nil? ? nil : open_time_entry.to_data_hash,
                           day_total_formatted: TimeEntry.total_formatted(work_effort: work_effort,
                                                                          party: party,
                                                                          start: time_helper.beginning_of_day,
                                                                          end: time_helper.end_of_day),
                           week_total_formatted: TimeEntry.total_formatted(work_effort: work_effort,
                                                                           party: party,
                                                                           start: time_helper.beginning_of_week,
                                                                           end: time_helper.end_of_week)
                 }
        else
          render :json => {success: true, time_entries: TimeEntry.open.collect { |time_entry| time_entry.to_data_hash }}
        end
      end

      # returns totals for time entries.  If a work effort id is passed it will get totals for the
      # passed work effort.  If no work effort id is passed it will get totals for the current user
      # passed on their timesheet
      #
      def totals
        result = {
            success: true,
            day_total_seconds: 0,
            week_total_seconds: 0,
            day_total_formatted: '00:00:00',
            week_total_formatted: '00:00:00',
            total_formatted: '00:00:00'
        }

        work_effort = nil
        party = nil
        time_helper = ErpBaseErpSvcs::Helpers::Time::Client.new(params[:client_utc_offset])

        if params[:work_effort_id]
          work_effort = WorkEffort.find(params[:work_effort_id])
        end

        if params[:party_id]
          party = Party.find(params[:party_id])
        end

        result[:day_total_seconds] = TimeEntry.total_seconds(work_effort: work_effort,
                                                             party: party,
                                                             start: time_helper.beginning_of_day,
                                                             end: time_helper.end_of_day
        )
        result[:week_total_seconds] = TimeEntry.total_seconds(work_effort: work_effort,
                                                              party: party,
                                                              start: time_helper.beginning_of_week,
                                                              end: time_helper.end_of_week
        )
        result[:total_seconds] = TimeEntry.total_seconds(work_effort: work_effort,
                                                         party: party
        )
        result[:day_total_formatted] = TimeEntry.total_formatted(work_effort: work_effort,
                                                                 party: party,
                                                                 start: time_helper.beginning_of_day,
                                                                 end: time_helper.end_of_day
        )
        result[:week_total_formatted] = TimeEntry.total_formatted(work_effort: work_effort,
                                                                  party: party,
                                                                  start: time_helper.beginning_of_week,
                                                                  end: time_helper.end_of_week
        )
        result[:total_formatted] = TimeEntry.total_formatted(work_effort: work_effort,
                                                             party: party
        )

        render json: result
      end

    end # TimeEntriesController
  end # V1
end # Api