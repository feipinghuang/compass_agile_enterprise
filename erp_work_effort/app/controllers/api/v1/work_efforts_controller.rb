module Api
  module V1
    class WorkEffortsController < BaseController

      def index
        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        work_efforts = WorkEffort.where("work_efforts.parent_id is null")

        # scope by user if that option is passed and no parties are passed to filter by
        if query_filter[:parties].blank? and params[:scope_by_user].present? and params[:scope_by_user].to_bool
          work_efforts = work_efforts.scope_by_user(current_user, {role_types: [RoleType.iid('work_resource')]})

          # scope by dba organization if we are not scoping by user or filtering by parties
        elsif query_filter[:parties].blank?
          dba_organizations = [current_user.party.dba_organization]
          dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
          work_efforts = work_efforts.scope_by_dba_organization(dba_organizations)
        end

        # apply filters
        work_efforts = WorkEffort.apply_filters(query_filter, work_efforts)

        work_efforts = work_efforts.order("sequence ASC").uniq

        render :json => {success: true,
                         total: work_efforts.count,
                         work_efforts: work_efforts.map { |work_effort| work_effort.to_data_hash }}

      end

      def show
        work_effort = WorkEffort.find(params[:id])

        respond_to do |format|
          # if a tree format was requested then respond with the children of this WorkEffort
          format.tree do
            render :json => {success: true, work_efforts: WorkEffort.where(parent_id: work_effort).order("sequence ASC").collect { |child| child.to_data_hash }}
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
          work_effort.start_at = Time.parse(data[:start_at]).in_time_zone.utc
        end

        if data[:end_at].present?
          work_effort.end_at = Time.parse(data[:end_at]).in_time_zone.utc
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

        if data[:status].present?
          work_effort.current_status = TrackedStatusType.find_by_ancestor_iids(['task_statuses', data[:status][:tracked_status_type][:internal_identifier]])
        end

        if data[:work_effort_type].present?
          work_effort.work_effort_type = WorkEffortType.iid(data[:work_effort_type][:internal_identifier])
        end

        work_effort.created_by_party = current_user.party

        work_effort.save!

        # set dba_org
        work_effort.add_party_with_role(current_user.party.dba_organization, RoleType.iid('dba_org'))

        # if scope by user set the current user relationship
        # scope by user if present
        if params[:scope_by_user].present? and params[:scope_by_user].to_bool
          work_resource_role_type = RoleType.find_or_create("work_resource", "Work Resource", RoleType.iid("application_composer"))
          WorkEffortPartyAssignment.create(work_effort: work_effort,
                                           role_type: work_resource_role_type,
                                           party: current_user.party)
        end

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
          work_effort.start_at = Time.parse(data[:start_at])
        end

        if data[:end_at].present?
          work_effort.end_at = Time.parse(data[:end_at])
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

        if data[:status].present?
          work_effort.current_status = TrackedStatusType.find_by_ancestor_iids(['task_statuses', data[:status][:tracked_status_type][:internal_identifier]])
        end

        if data[:work_effort_type].present?
          work_effort.work_effort_type = WorkEffortType.iid(data[:work_effort_type][:internal_identifier])
        end

        work_effort.updated_by_party = current_user.party

        work_effort.save!

        # if there is a parent move the node under that parent
        if data[:parent_id].present? and data[:parent_id] != 0
          parent = WorkEffort.find(data[:parent_id])
          work_effort.move_to_child_of(parent)

          # if there is no parent then move to root
        else
          work_effort.move_to_root
        end

        work_effort
      end

    end # WorkEffortsController
  end # V1
end # Api