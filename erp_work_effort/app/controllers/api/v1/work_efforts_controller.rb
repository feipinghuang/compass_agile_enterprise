module API
  module V1
    class WorkEffortsController < BaseController

=begin

 @api {get} /api/v1/work_efforts 
 @apiVersion 1.0.0
 @apiName GetWorkEfforts
 @apiGroup WorkEffort
 @apiDescription Get WorkEfforts

 @apiParam (query) {Integer} [project_id] Project ID to scope by
 @apiParam (query) {String} [status] Comma separated list of TrackedStatusType internal identifiers to scope by
 @apiParam (query) {String} [parties] JSON encoded object containing comma separated separated party ids and role types to scope by

 @apiSuccess (200) {Object} get_work_efforts_response 
 @apiSuccess (200) {Boolean} get_work_efforts_response.success True if the request was successful
 @apiSuccess (200) {Object[]} get_work_efforts_response.work_efforts List of WorkEfforts
 @apiSuccess (200) {Integer} get_work_efforts_response.work_efforts.id Id of WorkEffort
 @apiSuccess (200) {Boolean} get_work_efforts_response.work_efforts.leaf true If this WorkEffort is a leaf
 @apiSuccess (200) {Integer} get_work_efforts_response.work_efforts.parent_id Parent ID of WorkEffort
 @apiSuccess (200) {String} get_work_efforts_response.work_efforts.description Description of WorkEffort
 @apiSuccess (200) {DateTime} get_work_efforts_response.work_efforts.start_at Start At of WorkEffort
 @apiSuccess (200) {DateTime} get_work_efforts_response.work_efforts.end_at End At of WorkEffort
 @apiSuccess (200) {Decimal} get_work_efforts_response.work_efforts.percent_done Percent done of WorkEffort
 @apiSuccess (200) {Integer} get_work_efforts_response.work_efforts.duration Duration of WorkEffort
 @apiSuccess (200) {String} get_work_efforts_response.work_efforts.duration_unit Duration Unit of WorkEffort
 @apiSuccess (200) {Integer} get_work_efforts_response.work_efforts.effort Effort of WorkEffort
 @apiSuccess (200) {String} get_work_efforts_response.work_efforts.effort_unit Effort Unit of WorkEffort
 @apiSuccess (200) {String} get_work_efforts_response.work_efforts.comments Comments on WorkEffort
 @apiSuccess (200) {Integer} get_work_efforts_response.work_efforts.sequence Sequence of WorkEffort
 @apiSuccess (200) {DateTime} get_work_efforts_response.work_efforts.created_at When the WorkEffort was created
 @apiSuccess (200) {DateTime} get_work_efforts_response.work_efforts.updated_at When the WorkEffort was updated
 
=end

      def index
        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        work_efforts = WorkEffort

        if query_filter[:project_id].blank?
          # scope by user if that option is passed and no parties are passed to filter by
          if params[:scope_by_user].present? and params[:scope_by_user].to_bool
            work_efforts = work_efforts.scope_by_user(current_user, {role_types: [RoleType.iid('work_resource')]})

            # scope by dba organization if we are not scoping by user or filtering by parties and there is no project_id
          else
            dba_organizations = [current_user.party.dba_organization]
            dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
            work_efforts = work_efforts.scope_by_dba_organization(dba_organizations)
          end
        end

        # if there is no status filter default to all statues except complete
        if query_filter[:status].blank? && params[:business_module_id].present?
          unless completed_statuses.empty?
            work_efforts = work_efforts.without_current_status(completed_statuses)
          end
        end

        # apply filters
        work_efforts = WorkEffort.apply_filters(query_filter, work_efforts)

        if params[:node].blank?
          if query_filter.present?
            root_ids = work_efforts.all.collect{|item| item.root.id}.uniq
            if root_ids.count > 0
              # if there are filters and no parent we need to return roots that have the requested filters OR their children have the filters
              work_efforts = WorkEffort.where(WorkEffort.arel_table[:id].in(work_efforts.roots.select('work_efforts.id').to_sql).or(WorkEffort.arel_table[:id].in(root_ids.join(','))))
            end
          end
        else
          descendant_ids = WorkEffort.find(params[:node]).descendants.collect(&:id)

          parent_ids = work_efforts.where(WorkEffort.arel_table[:id].in(descendant_ids)).all.collect do |node|
            node.self_and_ancestors.collect do |ancestor|
              ancestor.id
            end
          end

          parent_ids = parent_ids.flatten.uniq

          node_sql = work_efforts.select('work_efforts.id').where(WorkEffort.arel_table[:parent_id].eq(params[:node])).to_sql
          parent_sql = WorkEffort.select('work_efforts.id').where(WorkEffort.arel_table[:parent_id].eq(params[:node])
                                                                  .and(WorkEffort.arel_table[:id].in(parent_ids))).to_sql

          work_efforts = WorkEffort.where("(id in (#{node_sql})) or (id in (#{parent_sql}))")
        end

        work_efforts = work_efforts.order("sequence ASC").uniq

        render :json => {success: true,
                         total: work_efforts.count,
                         work_efforts: work_efforts.map { |work_effort| work_effort.to_data_hash }}
      end

=begin

 @api {get} /api/v1/work_efforts/:id 
 @apiVersion 1.0.0
 @apiName GetWorkEffort
 @apiGroup WorkEffort
 @apiDescription Get WorkEffort

 @apiParam (query) {Integer} id WorkEffort Id

 @apiSuccess (200) {Object} get_work_effort_response 
 @apiSuccess (200) {Boolean} get_work_effort_response.success True if the request was successful
 @apiSuccess (200) {Object} get_work_effort_response.work_effort Work Effort record
 @apiSuccess (200) {Integer} get_work_effort_response.work_effort.id Id of WorkEffort
 @apiSuccess (200) {Boolean} get_work_effort_response.work_effort.leaf true If this WorkEffort is a leaf
 @apiSuccess (200) {Number} get_work_effort_response.work_effort.parent_id Parent ID of WorkEffort
 @apiSuccess (200) {String} get_work_effort_response.work_effort.description Description of WorkEffort
 @apiSuccess (200) {DateTime} get_work_effort_response.work_effort.start_at Start At of WorkEffort
 @apiSuccess (200) {DateTime} get_work_effort_response.work_effort.end_at End At of WorkEffort
 @apiSuccess (200) {Decimal} get_work_effort_response.work_effort.percent_done Percent done of WorkEffort
 @apiSuccess (200) {Integer} get_work_effort_response.work_effort.duration Duration of WorkEffort
 @apiSuccess (200) {String} get_work_effort_response.work_effort.duration_unit Duration Unit of WorkEffort
 @apiSuccess (200) {Integer} get_work_effort_response.work_effort.effort Effort of WorkEffort
 @apiSuccess (200) {String} get_work_effort_response.work_effort.effort_unit Effort Unit of WorkEffort
 @apiSuccess (200) {String} get_work_effort_response.work_effort.comments Comments on WorkEffort
 @apiSuccess (200) {Integer} get_work_effort_response.work_effort.sequence Sequence of WorkEffort
 @apiSuccess (200) {DateTime} get_work_effort_response.work_effort.created_at When the WorkEffort was created
 @apiSuccess (200) {DateTime} get_work_effort_response.work_effort.updated_at When the WorkEffort was updated

=end

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

=begin

  @api {post} /api/v1/work_efforts Create
  @apiVersion 1.0.0
  @apiName CreateWorkEffort
  @apiGroup WorkEffort
  @apiDescription Create WorkEffort

  @apiParam (body) {Integer} [project_id] ID of Project to create WorkEfforts under
  @apiParam (body) {Object[]} work_efforts Array of WorkEfforts to update
  @apiParam (body) {String} work_efforts.description Description of WorkEffort
  @apiParam (body) {DateTime} [work_efforts.start_at] Start At of WorkEffort
  @apiParam (body) {DateTime} [work_efforts.end_at] End At of WorkEffort
  @apiParam (body) {Decimal} [work_efforts.percent_done] Percent done of WorkEffort
  @apiParam (body) {Integer} [work_efforts.duration] Duration of WorkEffort
  @apiParam (body) {String} [work_efforts.duration_unit] Duration Unit of WorkEffort
  @apiParam (body) {Integer} [work_efforts.effort] Effort of WorkEffort
  @apiParam (body) {String} [work_efforts.effort_unit] Effort Unit of WorkEffort
  @apiParam (body) {String} [work_efforts.comments] Comments on WorkEffort
  @apiParam (body) {Integer} [work_efforts.sequence] Sequence of WorkEffort
  @apiParam (body) {Integer} [work_efforts.parent_id ID] of Parent WorkEffort to put the newly created WorkEfforts under
  @apiParam (body) {Integer} [work_efforts.biz_txn_event_id] BizTxnEvent to relate to this WorkEffort
 
  @apiSuccess (200) {Object} create_work_effort_response 
  @apiSuccess (200) {Boolean} create_work_effort_response.success True if the request was successful
  @apiSuccess (200) {Object[]} create_work_effort_response.work_efforts Array of created WorkEfforts
  @apiSuccess (200) {Integer} create_work_effort_response.work_efforts.id Id of WorkEffort
  @apiSuccess (200) {Boolean} create_work_effort_response.work_efforts.leaf true If this WorkEffort is a leaf
  @apiSuccess (200) {Integer} create_work_effort_response.work_efforts.parent_id Parent ID of WorkEffort
  @apiSuccess (200) {String} create_work_effort_response.work_efforts.description Description of WorkEffort
  @apiSuccess (200) {DateTime} create_work_effort_response.work_efforts.start_at Start At of WorkEffort
  @apiSuccess (200) {DateTime} create_work_effort_response.work_efforts.end_at End At of WorkEffort
  @apiSuccess (200) {Decimal} create_work_effort_response.work_efforts.percent_done Percent done of WorkEffort
  @apiSuccess (200) {Integer} create_work_effort_response.work_efforts.duration Duration of WorkEffort
  @apiSuccess (200) {String} create_work_effort_response.work_efforts.duration_unit Duration Unit of WorkEffort
  @apiSuccess (200) {Integer} create_work_effort_response.work_efforts.effort Effort of WorkEffort
  @apiSuccess (200) {String} create_work_effort_response.work_efforts.effort_unit Effort Unit of WorkEffort
  @apiSuccess (200) {String} create_work_effort_response.work_efforts.comments Comments on WorkEffort
  @apiSuccess (200) {Number} create_work_effort_response.work_efforts.sequence Sequence of WorkEffort
  @apiSuccess (200) {DateTime} create_work_effort_response.work_efforts.created_at When the WorkEffort was created
  @apiSuccess (200) {DateTime} create_work_effort_response.work_efforts.updated_at When the WorkEffort was updated

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
  @apiDescription Update WorkEffort

  @apiParam (query) {Integer} id WorkEffort Id

  @apiParam (body) {Integer} [project_id] ID of Project to put WorkEfforts under
  @apiParam (body) {Object[]} work_efforts Array of WorkEfforts to create
  @apiParam (body) {String} [work_efforts.description] Description of WorkEffort
  @apiParam (body) {DateTime} [work_efforts.start_at] Start At of WorkEffort
  @apiParam (body) {DateTime} [work_efforts.end_at] End At of WorkEffort
  @apiParam (body) {Decimal} [work_efforts.percent_done] Percent done of WorkEffort
  @apiParam (body) {Integer} [work_efforts.duration] Duration of WorkEffort
  @apiParam (body) {String} [work_efforts.duration_unit] Duration Unit of WorkEffort
  @apiParam (body) {Integer} [work_efforts.effort] Effort of WorkEffort
  @apiParam (body) {String} [work_efforts.effort_unit] Effort Unit of WorkEffort
  @apiParam (body) {String} [work_efforts.comments] Comments on WorkEffort
  @apiParam (body) {Integer} [work_efforts.sequence] Sequence of WorkEffort
  @apiParam (body) {Integer} [work_efforts.parent_id ID] of Parent WorkEffort to put the updated WorkEfforts under

  @apiSuccess (200) {Object} update_work_effort_response 
  @apiSuccess (200) {Boolean} update_work_effort_response.success True if the request was successful
  @apiSuccess (200) {Object[]} update_work_effort_response.work_efforts Array of updated WorkEfforts
  @apiSuccess (200) {Integer} update_work_effort_response.work_efforts.id Id of WorkEffort
  @apiSuccess (200) {Boolean} update_work_effort_response.work_efforts.leaf true If this WorkEffort is a leaf
  @apiSuccess (200) {Integer} update_work_effort_response.work_efforts.parent_id Parent ID of WorkEffort
  @apiSuccess (200) {String} update_work_effort_response.work_efforts.description Description of WorkEffort
  @apiSuccess (200) {DateTime} update_work_effort_response.work_efforts.start_at Start At of WorkEffort
  @apiSuccess (200) {DateTime} update_work_effort_response.work_efforts.end_at End At of WorkEffort
  @apiSuccess (200) {Decimal} update_work_effort_response.work_efforts.percent_done Percent done of WorkEffort
  @apiSuccess (200) {Integer} update_work_effort_response.work_efforts.duration Duration of WorkEffort
  @apiSuccess (200) {String} update_work_effort_response.work_efforts.duration_unit Duration Unit of WorkEffort
  @apiSuccess (200) {Integer} update_work_effort_response.work_efforts.effort Effort of WorkEffort
  @apiSuccess (200) {String} update_work_effort_response.work_efforts.effort_unit Effort Unit of WorkEffort
  @apiSuccess (200) {String} update_work_effort_response.work_efforts.comments Comments on WorkEffort
  @apiSuccess (200) {Integer} update_work_effort_response.work_efforts.sequence Sequence of WorkEffort
  @apiSuccess (200) {DateTime} update_work_effort_response.work_efforts.created_at When the WorkEffort was created
  @apiSuccess (200) {DateTime} update_work_effort_response.work_efforts.updated_at When the WorkEffort was updated

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

  @api {delete} /api/v1/work_efforts/:id
  @apiVersion 1.0.0
  @apiName DeleteWorkEffort
  @apiGroup WorkEffort
  @apiDescription Delete WorkEffort
 
  @apiParam (query) {Integer} id WorkEffort Id

  @apiSuccess (200) {Object} delete_work_effort_response 
  @apiSuccess (200) {Boolean} delete_work_effort_response.success True if the request was successful

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

=begin

  @api {get} /api/v1/work_efforts/:id/time_entries_allowed
  @apiVersion 1.0.0
  @apiName WorkEffortTimeEntriesAllowed
  @apiGroup WorkEffort
  @apiDescription Time Entries Allowed
  
  @apiParam (query) {Integer} id WorkEffort Id
  
  @apiSuccess (200) {Object} time_entries_allowed_work_effort_response 
  @apiSuccess (200) {Boolean} time_entries_allowed_work_effort_response.success True if the request was successful
  @apiSuccess (200) {Boolean} time_entries_allowed_work_effort_response.allowed True if time entries are allowed

=end

      def time_entries_allowed
        work_effort = WorkEffort.find(params[:id])
        party = params[:party_id].blank? ? current_user.party : Party.find(params[:party_id])

        render json: {success: true, allowed: work_effort.time_entries_allowed?(party)}
      end

=begin

  @api {put} /api/v1/work_efforts/:id/update_status
  @apiVersion 1.0.0
  @apiName UpdateWorkEffortStatus
  @apiGroup WorkEffort
  @apiDescription Update status of WorkEffort
   
  @apiParam (query) {Integer} id WorkEffort Id
  @apiParam (body) {String} status Internal identifier of status that should be set

  @apiSuccess (200) {Object} update_status_work_effort_response 
  @apiSuccess (200) {Boolean} update_status_work_effort_response.success True if the request was successful

=end

      def update_status
        work_effort = WorkEffort.find(params[:id])

        work_effort.current_status = params[:status]

        render :json => {:success => true}
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
          if data[:status].is_a? String
            work_effort.current_status = TrackedStatusType.iid(data[:status])
          else
            work_effort.current_status = TrackedStatusType.iid(data[:status][:tracked_status_type][:internal_identifier])
          end
        end

        if data[:work_effort_type].present?
          if data[:work_effort_type].is_a? String
            work_effort.work_effort_type = WorkEffortType.iid(data[:work_effort_type])
          else
            work_effort.work_effort_type = WorkEffortType.iid(data[:work_effort_type][:internal_identifier])
          end
        end

        if data[:biz_txn_event_id].present?
          work_effort.biz_txn_events << BizTxnEvent.find(data[:biz_txn_event_id])
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
          if data[:status].is_a? String
            work_effort.current_status = TrackedStatusType.iid(data[:status])
          else
            work_effort.current_status = TrackedStatusType.iid(data[:status][:tracked_status_type][:internal_identifier])
          end
        end

        if data[:work_effort_type].present?
          if data[:work_effort_type].is_a? String
            work_effort.work_effort_type = WorkEffortType.iid(data[:work_effort_type])
          else
            work_effort.work_effort_type = WorkEffortType.iid(data[:work_effort_type][:internal_identifier])
          end
        end

        work_effort.updated_by_party = current_user.party

        work_effort.save!

        # if there is a parent move the node under that parent
        if data[:parent_id].present? and data[:parent_id] != 0
          parent = WorkEffort.find(data[:parent_id])
          work_effort.move_to_child_of(parent)

          # if there is no parent then move to root
        elsif data[:parent_id] == 'root'
          work_effort.move_to_root
        end

        work_effort
      end

      private

      def completed_statuses
        business_module = BusinessModule.find(params[:business_module_id])
        if business_module.is_sub_module?
          completed_status = business_module.parent.meta_data['completed_status']
        else
          completed_status = business_module.meta_data['completed_status']
        end

        if completed_status
          completed_status.split(',')
        else
          []
        end
      end

    end # WorkEffortsController
  end # V1
end # API
