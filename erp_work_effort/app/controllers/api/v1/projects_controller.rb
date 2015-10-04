module Api
  module V1
    class ProjectsController < BaseController

=begin

  @api {get} /api/v1/projects Index
  @apiVersion 1.0.0
  @apiName GetWorkProjects
  @apiGroup Project

  @apiSuccess {Boolean} success True if the request was successful
  @apiSuccess {Array} projects List of Projects
  @apiSuccess {Number} projects.id Id of Project
  @apiSuccess {String} projects.description Description of Project
  @apiSuccess {DateTime} projects.created_at When the Project was created
  @apiSuccess {DateTime} projects.updated_at When the Project was updated

=end

      def index
        # scope by dba organization
        projects = Project.with_party_role(current_user.party.dba_organization, RoleType.iid('dba_org'))

        render :json => {success: true, projects: projects.all.map { |project| project.to_data_hash }}
      end

    end # ProjectsController
  end # V1
end # Api