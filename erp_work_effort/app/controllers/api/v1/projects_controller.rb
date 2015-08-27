module Api
  module V1
    class ProjectsController < BaseController

      def index
        # scope by dba organization
        projects = Project.with_party_role(current_user.party.dba_organization, RoleType.iid('dba_org'))

        render :json => {success: true, projects: projects.all.map { |project| project.to_data_hash }}
      end

    end # ProjectsController
  end # V1
end # Api