require 'rake'
require 'factory_girl'
require 'rails/generators'

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
DUMMY_APP_ROOT=File.join(File.dirname(__FILE__), '/dummy')

require 'active_support'
require 'active_model'
require 'active_record'
require 'action_controller'

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "spec"
require File.expand_path(DUMMY_APP_ROOT + "/config/environment.rb",  __FILE__)

ActiveRecord::Base.configurations = YAML::load(IO.read(DUMMY_APP_ROOT + "/config/database.yml"))
ActiveRecord::Base.establish_connection(ENV["DB"] || "spec")
ActiveRecord::Migration.verbose = false

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

require 'rspec/rails'
require 'erp_dev_svcs'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = false

  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.include ErpDevSvcs
end

#We have to execute the migrations from dummy app directory
Dir.chdir DUMMY_APP_ROOT
`rake db:drop RAILS_ENV=spec`

puts 'Cleaning out migrations'
`rm -R db/migrate/*`
`rm -R db/data_migrations/*`

Dir.chdir ENGINE_RAILS_ROOT

#We have to execute the migratiapp:compass_ae:install:data_migrationsons from dummy app directory
Dir.chdir DUMMY_APP_ROOT

puts 'Running migrations'
`rake compass_ae:install:migrations RAILS_ENV=spec`
`rake compass_ae:install:data_migrations RAILS_ENV=spec`
`rake db:migrate RAILS_ENV=spec`
`rake db:migrate_data RAILS_ENV=spec`

Dir.chdir ENGINE_RAILS_ROOT

ErpDevSvcs::FactorySupport.load_engine_factories

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter "spec/"
end

# Need to explictly load the files in lib/ until we figure out how to
# get rails to autoload them for spec like it used to...
Dir[File.join(ENGINE_RAILS_ROOT, "lib/**/*.rb")].each {|f| load f}
Dir[File.join(ENGINE_RAILS_ROOT, "app/models/extensions/**/*.rb")].each {|f| load f}
