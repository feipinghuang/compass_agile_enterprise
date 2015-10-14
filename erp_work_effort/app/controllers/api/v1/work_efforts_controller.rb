module Api
  module V1
    class WorkEffortsController < BaseController

=begin

 @api {get} /api/v1/work_efforts Index
 @apiVersion 1.0.0
 @apiName GetWorkEfforts
 @apiGroup WorkEffort

 @apiParam {Number} [project_id] Project ID to scope by
 @apiParam {String} [status] Comma separated list of TrackedStatusType internal identifiers to scope by
 @apiParam {String} [parties] JSON encoded object containing comma separated separated party ids and role types to scope by

 @apiSuccess {Boolean} success True if the request was successful
 @apiSuccess {Array} work_efforts List of WorkEfforts
 @apiSuccess {Number} work_efforts.id Id of WorkEffort
 @apiSuccess {Boolean} work_efforts.leaf true If this WorkEffort is a leaf
 @apiSuccess {Number} work_efforts.parent_id Parent ID of WorkEffort
 @apiSuccess {String} work_efforts.description Description of WorkEffort
 @apiSuccess {DateTime} work_efforts.start_at Start At of WorkEffort
 @apiSuccess {DateTime} work_efforts.end_at End At of WorkEffort
 @apiSuccess {Decimal} work_efforts.percent_done Percent done of WorkEffort
 @apiSuccess {Number} work_efforts.duration Duration of WorkEffort
 @apiSuccess {String} work_efforts.duration_unit Duration Unit of WorkEffort
 @apiSuccess {Number} work_efforts.effort Effort of WorkEffort
 @apiSuccess {String} work_efforts.effort_unit Effort Unit of WorkEffort
 @apiSuccess {String} work_efforts.comments Comments on WorkEffort
 @apiSuccess {Number} work_efforts.sequence Sequence of WorkEffort
 @apiSuccess {DateTime} work_efforts.created_at When the WorkEffort was created
 @apiSuccess {DateTime} work_efforts.updated_at When the WorkEffort was updated

=end

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

=begin

 @api {get} /api/v1/work_efforts/:id Show
 @apiVersion 1.0.0
 @apiName GetWorkEffort
 @apiGroup WorkEffort

 @apiSuccess {Boolean} success True if the request was successful
 @apiSuccess {Object} work_effort Work Effort record
 @apiSuccess {Number} work_effort.id Id of WorkEffort
 @apiSuccess {Boolean} work_effort.leaf true If this WorkEffort is a leaf
 @apiSuccess {Number} work_effort.parent_id Parent ID of WorkEffort
 @apiSuccess {String} work_effort.description Description of WorkEffort
 @apiSuccess {DateTime} work_effort.start_at Start At of WorkEffort
 @apiSuccess {DateTime} work_effort.end_at End At of WorkEffort
 @apiSuccess {Decimal} work_effort.percent_done Percent done of WorkEffort
 @apiSuccess {Number} work_effort.duration Duration of WorkEffort
 @apiSuccess {String} work_effort.duration_unit Duration Unit of WorkEffort
 @apiSuccess {Number} work_effort.effort Effort of WorkEffort
 @apiSuccess {String} work_effort.effort_unit Effort Unit of WorkEffort
 @apiSuccess {String} work_effort.comments Comments on WorkEffort
 @apiSuccess {Number} work_effort.sequence Sequence of WorkEffort
 @apiSuccess {DateTime} work_effort.created_at When the WorkEffort was created
 @apiSuccess {DateTime} work_effort.updated_at When the WorkEffort was updated

=end

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

=begin

  @api {post} /api/v1/work_efforts Create
  @apiVersion 1.0.0
  @apiName CreateWorkEffort
  @apiGroup WorkEffort

  @apiParam {Number} [project_id] ID of Project to create WorkEfforts under
  @apiParam {Array} work_efforts Array of WorkEfforts to update
  @apiParam {String} work_efforts.description Description of WorkEffort
  @apiParam {DateTime} [work_efforts.start_at] Start At of WorkEffort
  @apiParam {DateTime} [work_efforts.end_at] End At of WorkEffort
  @apiParam {Decimal} [work_efforts.percent_done] Percent done of WorkEffort
  @apiParam {Number} [work_efforts.duration] Duration of WorkEffort
  @apiParam {String} [work_efforts.duration_unit] Duration Unit of WorkEffort
  @apiParam {Number} [work_efforts.effort] Effort of WorkEffort
  @apiParam {String} [work_efforts.effort_unit] Effort Unit of WorkEffort
  @apiParam {String} [work_efforts.comments] Comments on WorkEffort
  @apiParam {Number} [work_efforts.sequence] Sequence of WorkEffort
  @apiParam {Number} [work_efforts.parent_id ID] of Parent WorkEffort to put the newly created WorkEfforts under

  @apiSuccess {Boolean} success True if the request was successful
  @apiSuccess {Array} work_efforts Array of created WorkEfforts
  @apiSuccess {Number} work_efforts.id Id of WorkEffort
  @apiSuccess {Boolean} work_efforts.leaf true If this WorkEffort is a leaf
  @apiSuccess {Number} work_efforts.parent_id Parent ID of WorkEffort
  @apiSuccess {String} work_efforts.description Description of WorkEffort
  @apiSuccess {DateTime} work_efforts.start_at Start At of WorkEffort
  @apiSuccess {DateTime} work_efforts.end_at End At of WorkEffort
  @apiSuccess {Decimal} work_efforts.percent_done Percent done of WorkEffort
  @apiSuccess {Number} work_efforts.duration Duration of WorkEffort
  @apiSuccess {String} work_efforts.duration_unit Duration Unit of WorkEffort
  @apiSuccess {Number} work_efforts.effort Effort of WorkEffort
  @apiSuccess {String} work_efforts.effort_unit Effort Unit of WorkEffort
  @apiSuccess {String} work_efforts.comments Comments on WorkEffort
  @apiSuccess {Number} work_efforts.sequence Sequence of WorkEffort
  @apiSuccess {DateTime} work_efforts.created_at When the WorkEffort was created
  @apiSuccess {DateTime} work_efforts.updated_at When the WorkEffort was updated

=end

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

=begin

  @api {put} /api/v1/work_efforts/:id Update
  @apiVersion 1.0.0
  @apiName UpdateWorkEffort
  @apiGroup WorkEffort

  @apiParam {Number} [project_id] ID of Project to put WorkEfforts under
  @apiParam {Array} work_efforts Array of WorkEfforts to create
  @apiParam {String} [work_efforts.description] Description of WorkEffort
  @apiParam {DateTime} [work_efforts.start_at] Start At of WorkEffort
  @apiParam {DateTime} [work_efforts.end_at] End At of WorkEffort
  @apiParam {Decimal} [work_efforts.percent_done] Percent done of WorkEffort
  @apiParam {Number} [work_efforts.duration] Duration of WorkEffort
  @apiParam {String} [work_efforts.duration_unit] Duration Unit of WorkEffort
  @apiParam {Number} [work_efforts.effort] Effort of WorkEffort
  @apiParam {String} [work_efforts.effort_unit] Effort Unit of WorkEffort
  @apiParam {String} [work_efforts.comments] Comments on WorkEffort
  @apiParam {Number} [work_efforts.sequence] Sequence of WorkEffort
  @apiParam {Number} [work_efforts.parent_id ID] of Parent WorkEffort to put the updated WorkEfforts under

  @apiSuccess {Boolean} success True if the request was successful
  @apiSuccess {Array} work_efforts Array of created WorkEfforts
  @apiSuccess {Number} work_efforts.id Id of WorkEffort
  @apiSuccess {Boolean} work_efforts.leaf true If this WorkEffort is a leaf
  @apiSuccess {Number} work_efforts.parent_id Parent ID of WorkEffort
  @apiSuccess {String} work_efforts.description Description of WorkEffort
  @apiSuccess {DateTime} work_efforts.start_at Start At of WorkEffort
  @apiSuccess {DateTime} work_efforts.end_at End At of WorkEffort
  @apiSuccess {Decimal} work_efforts.percent_done Percent done of WorkEffort
  @apiSuccess {Number} work_efforts.duration Duration of WorkEffort
  @apiSuccess {String} work_efforts.duration_unit Duration Unit of WorkEffort
  @apiSuccess {Number} work_efforts.effort Effort of WorkEffort
  @apiSuccess {String} work_efforts.effort_unit Effort Unit of WorkEffort
  @apiSuccess {String} work_efforts.comments Comments on WorkEffort
  @apiSuccess {Number} work_efforts.sequence Sequence of WorkEffort
  @apiSuccess {DateTime} work_efforts.created_at When the WorkEffort was created
  @apiSuccess {DateTime} work_efforts.updated_at When the WorkEffort was updated

=end

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

=begin

  @api {delete} /api/v1/work_efforts/:id Delete
  @apiVersion 1.0.0
  @apiName DeleteWorkEffort
  @apiGroup WorkEffort

  @apiSuccess {Boolean} success True if the request was successful

=end

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