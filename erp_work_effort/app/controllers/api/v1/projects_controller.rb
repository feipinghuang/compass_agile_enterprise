module Api
  module V1
    class ProjectsController < BaseController

      def index
        render :json => {success: true, projects: Project.all.map { |project| project.to_data_hash }}
      end

    end # ProjectsController
  end # V1
end # Api