module Api
  module V1
    class ProjectsController < BaseController

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
end # Api