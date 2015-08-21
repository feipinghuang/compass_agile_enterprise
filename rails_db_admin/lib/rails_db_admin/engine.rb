module RailsDbAdmin
  class Engine < Rails::Engine
    isolate_namespace RailsDbAdmin

    config.rails_db_admin = RailsDbAdmin::Config

    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "images")
      Rails.application.config.assets.precompile += %w{ erp_app/desktop/applications/rails_db_admin/app.js }
      Rails.application.config.assets.precompile += %w{ erp_app/desktop/applications/rails_db_admin/app.css }
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)
    ::ErpApp::Widgets::Loader.load_compass_ae_widgets(config, self)


    ActiveSupport.on_load(:action_controller) do
      include RailsDbAdmin::Extensions::ActionController::ReportSupport::ActsAsReportController
    end


  end
end
