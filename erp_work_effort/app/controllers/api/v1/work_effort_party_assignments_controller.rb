module Api
  module V1
    class WorkEffortPartyAssignmentsController < BaseController

      def index
        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys
        limit = params[:limit] || 25
        start = params[:start] || 0

        work_effort_party_assignments = WorkEffortPartyAssignment

        # apply filters
        work_effort_party_assignments = WorkEffortPartyAssignment.apply_filters(query_filter, work_effort_party_assignments)

        # scope by dba organization
        if query_filter[:parties].blank?
          dba_organizations = [current_user.party.dba_organization]
          dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
          work_effort_party_assignments = work_effort_party_assignments.scope_by_dba_organization(dba_organizations)
        end

        work_effort_party_assignments = work_effort_party_assignments.uniq

        total_count = work_effort_party_assignments.count
        work_effort_party_assignments = work_effort_party_assignments.offset(start).limit(limit)

        render :json => {
                   success: true,
                   total_count: total_count,
                   work_effort_party_assignments: work_effort_party_assignments.all.collect do |work_effort_party_assignment|
                     work_effort_party_assignment.to_data_hash
                   end
               }
      end

      def create
        begin
          ActiveRecord::Base.connection.transaction do

            work_effort_party_assignment = WorkEffortPartyAssignment.new
            work_effort_party_assignment.party_id = params['party.id']
            work_effort_party_assignment.work_effort_id = params['work_effort.id']
            work_effort_party_assignment.role_type = RoleType.iid('work_resource')
            work_effort_party_assignment.resource_allocation = params[:resource_allocation]
            work_effort_party_assignment.save!

            # if the party assigned is not watching this task then make them a watcher
            current_watcher_relationship = EntityPartyRole.where('entity_record_type = ?
                                                                and entity_record_id = ?
                                                                and party_id = ?',
                                                                 'WorkEffort',
                                                                 work_effort_party_assignment.work_effort_id,
                                                                 work_effort_party_assignment.party_id).first

            unless current_watcher_relationship
              work_effort = work_effort_party_assignment.work_effort
              work_effort.add_party_with_role(work_effort_party_assignment.party, RoleType.iid('watcher'))
            end

            render :json => {success: true,
                             work_effort_party_assignment: work_effort_party_assignment.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error creating WorkEffortPartyAssignment'}
        end
      end

      def update

        begin
          ActiveRecord::Base.connection.transaction do

            work_effort_party_assignment = WorkEffortPartyAssignment.find(params[:id])
            work_effort_party_assignment.party_id = params['party.id']
            work_effort_party_assignment.work_effort_id = params['work_effort.id']
            work_effort_party_assignment.role_type = RoleType.iid('work_resource')
            work_effort_party_assignment.resource_allocation = params[:resource_allocation]

            render :json => {success: work_effort_party_assignment.save!,
                             work_effort_party_assignment: work_effort_party_assignment.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error updating WorkEffortPartyAssignment'}
        end

      end

      def destroy

        work_effort_party_assignment = WorkEffortPartyAssignment.find(params[:id])

        begin
          ActiveRecord::Base.connection.transaction do

            render json: {success: work_effort_party_assignment.destroy}

          end
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error destroying WorkEffortPartyAssignment'}
        end

      end

    end # WorkEffortPartyAssignmentsController
  end # V1
end # Api