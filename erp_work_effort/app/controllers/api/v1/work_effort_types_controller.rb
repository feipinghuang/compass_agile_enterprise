module Api
  module V1
    class WorkEffortTypesController < BaseController

      def index
        if !params[:parent].blank?
          parent = nil
          # create parent if it doesn't exist
          # if the parent param is a comma separated string then
          # the parent is nested from left to right
          params[:parent].split(',').each do |parent_iid|
            if parent
              parent = WorkEffortType.find_or_create(parent_iid, parent_iid.humanize, parent)
            else
              parent = WorkEffortType.find_or_create(parent_iid, parent_iid.humanize)
            end
          end

          respond_to do |format|
            format.tree do
              render :json => {success: true, work_effort_types: parent.children_to_tree_hash}
            end
            format.json do
              render :json => {success: true, work_effort_types: WorkEffortType.to_all_representation(parent)}
            end
          end

          # if ids are passed look up on the txn types with the ids passed
        elsif params[:ids]
          ids = params[:ids].split(',').compact

          work_effort_types = []

          ids.each do |id|
            # check if id is a integer if so fine by id
            if id.is_integer?
              work_effort_type = WorkEffortType.find(id)
            else
              work_effort_type = WorkEffortType.iid(id)
            end

            respond_to do |format|
              format.tree do
                data = work_effort_type.to_hash({
                                                only: [:id, :parent_id, :internal_identifier, :description],
                                                leaf: work_effort_type.leaf?,
                                                text: work_effort_type.to_label,
                                                children: []
                                            })

                parent = nil
                work_effort_types.each do |work_effort_type_hash|
                  if work_effort_type_hash[:id] == data[:parent_id]
                    parent = work_effort_type_hash
                  end
                end

                if parent
                  parent[:children].push(data)
                else
                  work_effort_types.push(data)
                end
              end
              format.json do
                work_effort_types.push(work_effort_type.to_hash(only: [:id, :description, :internal_identifier]))
              end
            end

          end

          render :json => {success: true, work_effort_types: work_effort_types}

          # get all txn types
        else

          respond_to do |format|
            format.tree do
              nodes = [].tap do |nodes|
                WorkEffortType.roots.each do |root|
                  nodes.push(root.to_tree_hash)
                end
              end

              render :json => {success: true, work_effort_types: nodes}
            end
            format.json do
              render :json => {success: true, work_effort_types: WorkEffortType.to_all_representation}
            end
          end

        end
      end

      def show
        work_effort_type = WorkEffortType.find(params[:id])

        render :json => {success: true, work_effort_type: [work_effort_type.to_data_hash]}
      end

    end # WorkEffortTypeController
  end # V1
end # Api