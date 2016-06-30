$:.push File.expand_path("../", __FILE__)

# Maintain your gem's version:
require "version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'compass_ae'
  s.version     = CompassAe::VERSION::STRING
  s.licenses    = ['GPL-3-LICENSE']
  s.summary     = 'Full ERP stack built on top of the Rails framework.'
  s.description = 'Full ERP stack with a CRM, CMS and mulitple ERP Modules based on Silverston data models'

  s.required_ruby_version     = '>= 1.9.2'
  s.required_rubygems_version = ">= 1.8.10"
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  
  s.homepage    = 'http://development.compassagile.com'
  
  s.add_dependency('compass_ae_starter_kit', '~> 4.2')
  s.add_dependency('erp_base_erp_svcs',      '~> 4.2')
  s.add_dependency('erp_tech_svcs',          '~> 4.2')
  s.add_dependency('erp_app',                '~> 4.2')
  s.add_dependency('compass_ae_console',     '~> 3.2')
  s.add_dependency('knitkit',                '~> 3.2')
  s.add_dependency('rails_db_admin',         '~> 3.2')
end
