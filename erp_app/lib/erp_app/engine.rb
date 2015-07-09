require 'will_paginate'

module ErpApp
  class Engine < Rails::Engine
    isolate_namespace ErpApp

    Mime::Type.register "tree", :tree

    config.erp_app = ErpApp::Config

    initializer "erp_app.merge_public" do |app|
      app.middleware.insert_before Rack::Runtime, ::ActionDispatch::Static, "#{root}/public"
    end

    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "images")

      Rails.application.config.assets.precompile += ["codemirror_compassae.js", "codemirror_compassae.css", "inflection.js"]

      # include css files
      Rails.application.config.assets.precompile += %w{ erp_app/shared/erp_app_shared.css erp_app/shared/compass-ext-all.css jquery_plugins/jquery.loadmask.css }
      Rails.application.config.assets.precompile += %w{ erp_app/login/main.css erp_app/desktop/base.css erp_app/organizer/base.css }
      Rails.application.config.assets.precompile += %w{ erp_app/desktop/applications/security_management/app.css }

      # include js files
      Rails.application.config.assets.precompile += %w{ jquery_plugins/jquery.address.min.js jquery_plugins/jquery.loadmask.min.js }
      Rails.application.config.assets.precompile += %w{ erp_app/jquery_support.js erp_app/utility.js erp_app/widgets.js }
      Rails.application.config.assets.precompile += %w{ erp_app/shared/erp_app_shared.js }
      Rails.application.config.assets.precompile += %w{ erp_app/authentication/compass_user.js }
      Rails.application.config.assets.precompile += %w{ erp_app/ecommerce/credit_card_window.js }
      Rails.application.config.assets.precompile += %w{ erp_app/login/mobile.js erp_app/login/window.js }
      Rails.application.config.assets.precompile += %w{ erp_app/login/mobile.js erp_app/login/ResetPassword.js }
      Rails.application.config.assets.precompile += %w{ erp_app/organizer/app.js }
      Rails.application.config.assets.precompile += %w{ erp_app/desktop/app.js }

      # add root shared directory
      Rails.application.config.assets.precompile += %w{ erp_app/shared/app.js }

      # add shared assets to included by Compass
      ErpApp::Config.shared_js_assets += %w{ erp_app/shared/erp_app_shared.js }
      ErpApp::Config.shared_css_assets += %w{ erp_app/shared/erp_app_shared.css erp_app/shared/compass-ext-all.css }

      #
      # include desktop applications
      #
      desktop_js_path = File.join("app", "assets", "javascripts", "erp_app", "desktop", "applications")
      desktop_css_path = File.join("app", "assets", "stylesheets", "erp_app", "desktop", "applications")

      # add app.js files for desktop apps to precompile
      Dir.foreach(root.join(desktop_js_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "desktop", "applications", dir, 'app.js')
      end

      # add app.css files for desktop apps to precompile
      Dir.foreach(root.join(desktop_css_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "desktop", "applications", dir, 'app.css')
      end

      # add Rails root app.js files for desktop apps to precompile
      Dir.foreach(Rails.root.join(desktop_js_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "desktop", "applications", dir, 'app.js')
      end if File.exists?(Rails.root.join(desktop_js_path))

      # add Rails root app.css files for desktop apps to precompile
      Dir.foreach(Rails.root.join(desktop_css_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "desktop", "applications", dir, 'app.css')
      end if File.exists?(Rails.root.join(desktop_css_path))

      #
      # include organizer applications
      #
      organizer_js_path = File.join("app", "assets", "javascripts", "erp_app", "organizer", "applications")
      organizer_css_path = File.join("app", "assets", "stylesheets", "erp_app", "organizer", "applications")

      # add app.js files for organizer apps to precompile
      Dir.foreach(root.join(organizer_js_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "organizer", "applications", dir, 'app.js')
      end

      # add app.css files for organizer apps to precompile
      Dir.foreach(root.join(organizer_css_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "organizer", "applications", dir, 'app.css')
      end

      # add Rails root app.js files for organizer apps to precompile
      Dir.foreach(Rails.root.join(organizer_js_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "organizer", "applications", dir, 'app.js')
      end if File.exists?(Rails.root.join(organizer_js_path))

      # add Rails root app.css files for organizer apps to precompile
      Dir.foreach(Rails.root.join(organizer_css_path)) do |dir|
        next if dir == '.' or dir == '..'
        Rails.application.config.assets.precompile << File.join("erp_app", "organizer", "applications", dir, 'app.css')
      end if File.exists?(Rails.root.join(organizer_css_path))
    end

    ActiveSupport.on_load(:active_record) do
      include ErpApp::Extensions::ActiveRecord::HasUserPreferences
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)
    ::ErpApp::Widgets::Loader.load_root_widgets(config)

  end
end
