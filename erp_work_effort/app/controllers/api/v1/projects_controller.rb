module API
  module V1
    class ProjectsController < BaseController

=begin

  @api {get} /api/v1/projects Index
  @apiVersion 1.0.0
  @apiName GetWorkProjects
  @apiGroup Project
  @apiDescription Get Projects

  @apiSuccess (200) {Object} get_projects_response
  @apiSuccess (200) {Boolean} get_projects_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_projects_response.projects List of Projects
  @apiSuccess (200) {Number} get_projects_response.projects.id Id of Project
  @apiSuccess (200) {String} get_projects_response.projects.description Description of Project
  @apiSuccess (200) {DateTime} get_projects_response.projects.created_at When the Project was created
  @apiSuccess (200) {DateTime} get_projects_response.projects.updated_at When the Project was updated

=end

      def index
        # check if we are scoping by current user
        if params[:scope_by_user].present? and params[:scope_by_user].to_bool
          party = current_user.party
          projects = Project.scope_by_party(party,
                                            {role_types: RoleType.find_child_role_types(party.party_roles.collect { |party_role| party_role.role_type })})
        else
          # scope by dba organization
          projects = Project.scope_by_dba_organization(current_user.party.dba_organization)
        end

        if params[:query]
          projects = projects.where(projects.arel_table[:description].matches("%#{params[:query]}%"))
        end

        render :json => {success: true, projects: projects.all.map { |project| project.to_data_hash }}
      end

    end # ProjectsController
  end # V1
end # API
