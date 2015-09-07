class AdminToolGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :description, :type => :string 
  argument :icon, :type => :string 

  def generate_desktop_application
    # Controller
    template "controllers/controller_template.erb", "app/controllers/erp_app/desktop/#{file_name}/base_controller.rb"

    # make javascript
    template "assets/javascripts/Module.js.erb", "app/assets/javascripts/erp_app/desktop/applications/#{file_name}/Module.js"

    # make javascript manifest
    template "assets/javascripts/app.js.erb", "app/assets/javascripts/erp_app/desktop/applications/#{file_name}/app.js"

    # make css manifest
    template "assets/stylesheets/app.css.erb", "app/assets/stylesheets/erp_app/desktop/applications/#{file_name}/app.css"

    # make images folder
    empty_directory "app/assets/images/erp_app/desktop/applications/#{file_name}"
    
    # add route
    route "match '/erp_app/desktop/#{file_name}(/:action)' => \"erp_app/desktop/#{file_name}/base\""
    
    # migration
    template "migrate/migration_template.erb", "db/data_migrations/#{RussellEdge::DataMigrator.next_migration_number(1)}_create_#{file_name}_desktop_application.rb"
  end
end
