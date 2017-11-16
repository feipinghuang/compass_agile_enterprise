module API
  module V1
    class RoleTypesController < BaseController

=begin
 @api {get} /api/v1/role_types
 @apiVersion 1.0.0
 @apiName GetRoleTypes
 @apiGroup RoleType
 @apiDescription Get RoleTypes
 
 @apiSuccess (200) {Object} get_role_types_response Response
 @apiSuccess (200) {Boolean} get_role_types_response.success True if the request was successful.
 @apiSuccess (200) {Number} get_role_types_response.total_count Total count of records based on any filters applied.
 @apiSuccess (200) {Object[]} get_role_types_response.role_types List of RoleType records.
 @apiSuccess (200) {Number} get_role_types_response.role_types.id Id of RoleType.
=end

      def index
        if params[:party_id].present?
          party = Party.find(params[:party_id])

          render :json => {success: true, role_types: party.role_types.collect{|role_type| role_type.to_data_hash}}

        elsif params[:parent].present?
          parent = nil
          # create parent if it doesn't exist
          # if the parent param is a comma seperated string then
          # the parent is nested from left to right
          params[:parent].split(',').each do |parent_iid|
            if parent
              parent = RoleType.find_or_create(parent_iid, parent_iid.humanize, parent)
            else
              parent = RoleType.find_or_create(parent_iid, parent_iid.humanize)
            end
          end

          respond_to do |format|
            format.tree do
              render :json => {success: true, role_types: parent.children_to_tree_hash}
            end
            format.json do
              render :json => {success: true, role_types: RoleType.to_all_representation(parent)}
            end
          end

          # if ids are passed look up on the Role Types with the ids passed
        elsif params[:ids].present?
          ids = params[:ids].split(',').compact

          role_types = []

          ids.each do |id|
            # check if id is a integer if so fine by id
            if id.is_integer?
              role_type = RoleType.find(id)
            else
              role_type = RoleType.iid(id)
            end

            if role_type
              respond_to do |format|
                format.tree do
                  data = role_type.to_hash({
                                             only: [:id, :parent_id, :internal_identifier],
                                             leaf: role_type.leaf?,
                                             text: role_type.to_label,
                                             children: []
                  })

                  parent = nil
                  role_types.each do |role_type_hash|
                    if role_type_hash[:id] == data[:parent_id]
                      parent = role_type_hash
                    end
                  end

                  if parent
                    parent[:children].push(data)
                  else
                    role_types.push(data)
                  end
                end
                format.json do
                  role_types.push(role_type.to_hash(only: [:id, :description, :internal_identifier]))
                end
              end
            end

          end

          render :json => {success: true, role_types: role_types}

          # get all role types
        else
          respond_to do |format|
            format.tree do
              nodes = [].tap do |nodes|
                RoleType.roots.each do |root|
                  nodes.push(root.to_tree_hash)
                end
              end

              render :json => {success: true, role_types: nodes}
            end
            format.json do
              render :json => {success: true, role_types: RoleType.to_all_representation}
            end
          end

        end
      end

=begin
 @api {get} /api/v1/role_types/:id
 @apiVersion 1.0.0
 @apiName GetRoleType
 @apiGroup RoleType
 @apiDescription Get RoleType
 
 @apiParam (path) {Number} id Id of RoleType

 @apiSuccess (200) {Object} get_role_type_response Response
 @apiSuccess (200) {Boolean} get_role_type_response.success True if the request was successful.
 @apiSuccess (200) {Object[]} get_role_type_response.role_type List of RoleType records.
 @apiSuccess (200) {Number} get_role_type_response.role_type.id Id of RoleType.
=end

      def show
        id = params[:id]

        # check if id is a integer if so fine by id
        if id.is_integer?
          role_type = RoleType.find(id)
        else
          role_type = RoleType.iid(id)
        end

        respond_to do |format|
          format.tree do
            render :json => {success: true, role_type: role_type.to_tree_hash}
          end
          format.json do
            render :json => {success: true, role_type: role_type.to_hash(only: [:id, :description, :internal_identifier])}
          end
        end
      end

=begin
 @api {post} /api/v1/role_types
 @apiVersion 1.0.0
 @apiName CreateRoleType
 @apiGroup RoleType
 @apiDescription Create RoleType
 
 @apiParam (body) {String} description Description
 @apiParam (body) {String} [parent] If parent is sent and it is not 'No Parent' then it will be set as the parent of the new RoleType
 @apiParam (body) {String} [default_parent] If default_parent is sent it will be set as the parent of the new RoleType

 @apiSuccess (200) {Object} create_role_type_response Response
 @apiSuccess (200) {Boolean} create_role_type_response.success True if the request was successful.
 @apiSuccess (200) {Object[]} create_role_type_response.role_type RoleType record.
 @apiSuccess (200) {Number} create_role_type_response.role_type.id Id of RoleType.
=end

      def create
        description = params[:description].strip

        begin
          ActiveRecord::Base.transaction do
            role_type = RoleType.create!(description: description, internal_identifier: description.to_iid)

            if params[:parent] != 'No Parent'
              parent = RoleType.iid(params[:parent])
              role_type.move_to_child_of(parent)
            elsif params[:default_parent]
              parent = RoleType.iid(params[:default_parent])
              role_type.move_to_child_of(parent)
            end

            render :json => {success: true, role_type: role_type.to_hash(only: [:id, :description, :internal_identifier])}
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors.full_messages

          render :json => {:success => false, :message => invalid.record.errors.full_messages.join('</br>')}
        end
      end

    end # RoleTypesController
  end # V1
end # API
