module RailsDbAdmin
  class Engine < Rails::Engine
    isolate_namespace RailsDbAdmin

    config.rails_db_admin = RailsDbAdmin::Config

    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "images")
      Rails.application.config.assets.precompile += %w{ erp_app/desktop/applications/rails_db_admin/app.js }
      Rails.application.config.assets.precompile += ['bootstrap.css']

      Rails.application.config.assets.precompile += %w{ erp_app/shared/rails_db_admin_shared.js }
      Rails.application.config.assets.precompile += %w{ erp_app/shared/rails_db_admin_shared.css }

      ErpApp::Config.shared_js_assets += %w{ erp_app/shared/rails_db_admin_shared.js }
      ErpApp::Config.shared_css_assets += %w{ erp_app/shared/rails_db_admin_shared.css }
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)
    ::ErpApp::Widgets::Loader.load_compass_ae_widgets(config, self)

  end
end
