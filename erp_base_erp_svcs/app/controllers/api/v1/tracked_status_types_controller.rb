module API
  module V1
    class TrackedStatusTypesController < BaseController

=begin
 @api {get} /api/v1/tracked_status_types
 @apiVersion 1.0.0
 @apiName GetTrackedStatusTypes
 @apiGroup TrackedStatusType
 @apiDescription Get TrackedStatusTypes
 
 @apiSuccess (200) {Object} get_tracked_status_types_response Response
 @apiSuccess (200) {Boolean} get_tracked_status_types_response.success True if the request was successful.
 @apiSuccess (200) {Number} get_tracked_status_types_response.total_count Total count of records based on any filters applied.
 @apiSuccess (200) {Object[]} get_tracked_status_types_response.role_types List of TrackedStatusType records.
 @apiSuccess (200) {Number} get_tracked_status_types_response.role_types.id Id of TrackedStatusType.
=end

      def index
        # look up parent by internal identifier
        if params[:parent].present?
          parent = nil
          # create parent if it doesn't exist
          # if the parent param is a comma separated string then
          # the parent is nested from left to right
          params[:parent].split(',').each do |parent_iid|
            if parent
              parent = TrackedStatusType.find_or_create(parent_iid, parent_iid.humanize, parent)
            else
              parent = TrackedStatusType.find_or_create(parent_iid, parent_iid.humanize)
            end
          end

          respond_to do |format|
            format.tree do
              render :json => {success: true, tracked_status_types: parent.children_to_tree_hash}
            end
            format.json do
              render :json => {success: true, tracked_status_types: parent.children.all.collect{|item| item.to_data_hash}}
            end
            format.all_representation do

              total_count = TrackedStatusType.count

              render :json => {success: true,
                               total_count: total_count,
                               tracked_status_types: TrackedStatusType.to_all_representation(parent)}
            end
          end

          # if parent id is passed find parent and get its children
        elsif params[:parent_id].present?
          parent = TrackedStatusType.find(params[:parent_id])

          respond_to do |format|
            format.tree do
              render :json => {success: true, tracked_status_types: parent.children_to_tree_hash}
            end
            format.json do
              render :json => {success: true, tracked_status_types: parent.children.all.collect{|item| item.to_data_hash}}
            end
            format.all_representation do

              total_count = TrackedStatusType.count

              render :json => {success: true,
                               total_count: total_count,
                               tracked_status_types: TrackedStatusType.to_all_representation(TrackedStatusType.find(params[:parent_id]))}
            end
          end
          # if ids are passed look up on the Tracked Status Types with the ids passed
        elsif params[:ids].present?
          ids = params[:ids].split(',').compact

          tracked_status_types = []

          ids.each do |id|
            # check if id is a integer if so fine by id
            if id.is_integer?
              tracked_status_type = TrackedStatusType.find(id)
            else
              tracked_status_type = TrackedStatusType.iid(id)
            end

            respond_to do |format|
              format.tree do
                data = tracked_status_type.to_hash({
                                                     only: [:id, :parent_id, :internal_identifier],
                                                     leaf: tracked_status_type.leaf?,
                                                     text: tracked_status_type.to_label,
                                                     children: []
                })

                parent = nil
                tracked_status_types.each do |tracked_status_type_hash|
                  if tracked_status_type_hash[:id] == data[:parent_id]
                    parent = tracked_status_type_hash
                  end
                end

                if parent
                  parent[:children].push(data)
                else
                  tracked_status_types.push(data)
                end
              end
              format.json do
                tracked_status_types.push(tracked_status_type.to_data_hash)
              end
            end

          end

          render :json => {success: true, tracked_status_types: tracked_status_type}

          # get all TrackedStatusTypes
        else
          respond_to do |format|
            format.tree do
              nodes = [].tap do |nodes|
                TrackedStatusType.roots.each do |root|
                  nodes.push(root.to_tree_hash)
                end
              end

              render :json => {success: true, tracked_status_types: nodes}
            end
            format.json do
              render :json => {success: true, tracked_status_types: TrackedStatusType.where('parent_id is null').all.collect{|item| item.to_data_hash}}
            end
            format.all_representation do

              total_count = TrackedStatusType.count

              render :json => {success: true,
                               total_count: total_count,
                               tracked_status_types: TrackedStatusType.to_all_representation(nil, [], 0, TrackedStatusType.roots)}

            end
          end

        end
      end

=begin
 @api {get} /api/v1/tracked_status_types/:id
 @apiVersion 1.0.0
 @apiName GetTrackedStatusType
 @apiGroup TrackedStatusType
 @apiDescription Get TrackedStatusType
 
 @apiParam (path) {Number} id Id or Internal Identifier of TrackedStatusType

 @apiSuccess (200) {Object} get_tracked_status_type_response Response
 @apiSuccess (200) {Boolean} get_tracked_status_type_response.success True if the request was successful.
 @apiSuccess (200) {Object[]} get_tracked_status_type_response.role_type TrackedStatusType record.
 @apiSuccess (200) {Number} get_tracked_status_type_response.role_type.id Id of TrackedStatusType.
=end

      def show
        id = params[:id]

        # check if id is a integer if so fine by id
        if id.is_integer?
          tracked_status_type = TrackedStatusType.find(id)
        else
          tracked_status_type = TrackedStatusType.iid(id)
        end

        respond_to do |format|
          format.tree do
            render :json => {success: true, tracked_status_type: tracked_status_type.to_tree_hash}
          end
          format.json do
            render :json => {success: true, tracked_status_type: tracked_status_type.to_data_hash}
          end
        end
      end

=begin
 @api {post} /api/v1/tracked_status_types
 @apiVersion 1.0.0
 @apiName CreateTrackedStatusType
 @apiGroup TrackedStatusType
 @apiDescription Create TrackedStatusType
 
 @apiParam (body) {String} description Description
 @apiParam (body) {String} [parent] If parent is sent and it is not 'No Parent' then it will be set as the parent of the new TrackedStatusType
 @apiParam (body) {String} [default_parent] If default_parent is sent it will be set as the parent of the new TrackedStatusType

 @apiSuccess (200) {Object} create_tracked_status_type_response Response
 @apiSuccess (200) {Boolean} create_tracked_status_type_response.success True if the request was successful.
 @apiSuccess (200) {Object[]} create_tracked_status_type_response.role_type TrackedStatusType record.
 @apiSuccess (200) {Number} create_tracked_status_type_response.role_type.id Id of TrackedStatusType.
=end

      def create
        description = params[:description].strip

        ActiveRecord::Base.transaction do
          tracked_status_type = TrackedStatusType.create(description: description, internal_identifier: description.to_iid)

          if params[:parent] != 'No Parent'
            parent = TrackedStatusType.iid(params[:parent])
            tracked_status_type.move_to_child_of(parent)
          elsif params[:default_parent]
            parent = TrackedStatusType.iid(params[:default_parent])
            tracked_status_type.move_to_child_of(parent)
          end

          render :json => {success: true, tracked_status_type: tracked_status_type.to_data_hash}
        end
      end

    end # TrackedStatusTypesController
  end # V1
end # API
