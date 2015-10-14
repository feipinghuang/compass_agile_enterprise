module Api
  module V1
    class WorkEffortsController < BaseController

      def index

        work_efforts = WorkEffort.where("work_efforts.parent_id is null")

        # if project is passed scope by project
        if params[:project_id].present?
          work_efforts = work_efforts.scope_by_project(params[:project_id])
        end

        # if status is passed scope by status
        if params[:status].present?
          work_efforts = work_efforts.with_current_status(params[:status].split(','))
        end

        # if parties is passed scope by parties
        if params[:parties].present?
          data = JSON.parse(params[:parties])
          party_ids = data['party_ids']
          role_types = data['role_types']

          work_efforts = work_efforts.scope_by_party(party_ids.split(','), {role_types: RoleType.where('internal_identifier' => role_types.split(','))})
        end

        # scope by dba organization
        work_efforts = work_efforts.scope_by_dba_organization(current_user.party.dba_organization)

        work_efforts = work_efforts.order("sequence, created_at ASC")

        render :json => {success: true,
                         total: work_efforts.count,
                         work_efforts: work_efforts.map { |work_effort| work_effort.to_data_hash }}

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

          render json: {success: false, message: 'Error destroying Work Effort'}
        end
      end

      protected

      def create_work_effort(data)
        work_effort = WorkEffort.new
        work_effort.description = data[:description].strip

        if params[:project_id].present?
          if params[:project_id].to_i != 0
            work_effort.project_id = params[:project_id]
          end
        end

        if data[:start_at].present?
          work_effort.start_at = Time.strptime(params[:start_at], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
        end

        if data[:end_at].present?
          work_effort.end_at = Time.strptime(params[:end_at], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
        end

        if data[:percent_done].present?
          work_effort.percent_done = data[:percent_done]
        end

        if data[:duration].present?
          work_effort.duration = data[:duration]
        end

        if data[:duration_unit].present?
          work_effort.duration_unit = data[:duration_unit]
        end

        if data[:effort].present?
          work_effort.effort = data[:effort]
        end

        if data[:effort_unit].present?
          work_effort.effort_unit = data[:effort_unit]
        end

        if data[:comments].present?
          work_effort.comments = data[:comments].strip
        end

        if data[:sequence].present?
          work_effort.sequence = data[:sequence]
        end

        if data[:status_description].present?
          work_effort.current_status = TrackedStatusType.find_by_ancestor_iids(['task_statuses', data[:status_description].underscore.gsub(' ','_')])
        end

        work_effort.save!

        # set dba_org
        work_effort.add_party_with_role(current_user.party.dba_organization, RoleType.iid('dba_org'))

        if data[:parent_id].present? and data[:parent_id] != 0
          parent = WorkEffort.find(data[:parent_id])
          work_effort.move_to_child_of(parent)
          work_effort.reload
        end

        work_effort
      end

      def update_work_effort(data)
        work_effort = WorkEffort.find(data[:id])

        if data[:description].present?
          work_effort.description = data[:description].strip
        end

        if data[:start_at].present?
          work_effort.start_at = Time.parse(params[:start_at])
        end

        if data[:end_at].present?
          work_effort.end_at = Time.parse(params[:end_at])
        end

        if data[:percent_done].present?
          work_effort.percent_done = data[:percent_done]
        end

        if data[:duration].present?
          work_effort.duration = data[:duration]
        end

        if data[:duration_unit].present?
          work_effort.duration_unit = data[:duration_unit]
        end

        if data[:effort].present?
          work_effort.effort = data[:effort]
        end

        if data[:effort_unit].present?
          work_effort.effort_unit = data[:effort_unit]
        end

        if data[:comments].present?
          work_effort.comments = data[:comments].strip
        end

        if data[:sequence].present?
          work_effort.sequence = data[:sequence]
        end

        if data[:status_description].present?
          work_effort.current_status = TrackedStatusType.find_by_ancestor_iids(['task_statuses', data[:status_description].underscore.gsub(' ','_')])
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