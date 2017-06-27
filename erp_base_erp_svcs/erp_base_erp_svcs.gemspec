$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_base_erp_svcs/version"

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_base_erp_svcs"
  s.version     = ErpBaseErpSvcs::VERSION::STRING
  s.licenses    = ['GPL-3-LICENSE']
  s.summary     = "contains an implementation of the ubiquitous 'party model' for managing people, organizations, roles, relationships and contact information."
  s.description = "contains an implementation of the ubiquitous 'party model' for managing people, organizations, roles, relationships and contact information. The models in this library are designed to be useful in a variety of circumstances, including headless SOA implementations and batch operations."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.files       = Dir["{public,app,config,db,lib,tasks}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency('attr_encrypted','~> 3.0.3')
  s.add_dependency('awesome_nested_set','~> 2.1')
  s.add_dependency('data_migrator','~> 2.0')
  s.add_dependency('has_many_polymorphic','~> 2.0')
  s.add_dependency('uuid','2.3.5')
  s.add_dependency 'wisper', '1.6.0'

  s.add_development_dependency "cucumber-rails", "~> 1.3"
  s.add_development_dependency "database_cleaner", '~> 0'
  s.add_development_dependency "factory_girl_rails", "~> 4.1"
  s.add_development_dependency "rspec-rails", "~> 2.12"
  s.add_development_dependency "simplecov", "~> 0.7"
  s.add_development_dependency "spork", "~> 0.9"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "watchr", "~> 0.7"
  s.add_dependency "acts_as_list", "~> 0.9.5"

end
