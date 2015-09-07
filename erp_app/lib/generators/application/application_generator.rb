class ApplicationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :description, :type => :string 
  argument :menu_item_url, :type => :string

  def generate_desktop_application
    # Controller
    template "controllers/controller_template.erb", "app/controllers/erp_app/organizer/#{file_name}/base_controller.rb"

    # make javascript
    template "assets/javascripts/Application.js.erb", "app/assets/javascripts/erp_app/organizer/applications/#{file_name}/Application.js"

    # make javascript manifest
    template "assets/javascripts/app.js.erb", "app/assets/javascripts/erp_app/organizer/applications/#{file_name}/app.js"

    # make css manifest
    template "assets/stylesheets/app.css.erb", "app/assets/stylesheets/erp_app/organizer/applications/#{file_name}/app.css"

    # make images folder
    empty_directory "app/assets/images/erp_app/organizer/applications/#{file_name}"
    
    # add route
    route "match '/erp_app/organizer/#{file_name}(/:action)' => \"erp_app/organizer/#{file_name}/base\""
    
    # migration
    template "migrate/migration_template.erb", "db/data_migrations/#{RussellEdge::DataMigrator.next_migration_number(1)}_create_#{file_name}_application.rb"
  end
end
