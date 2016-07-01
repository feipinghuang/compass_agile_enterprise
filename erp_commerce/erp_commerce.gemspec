$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "erp_commerce/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "erp_commerce"
  s.version     = ErpCommerce::VERSION::STRING
  s.licenses    = ['GPL-3-LICENSE']
  s.summary     = "The CompassAE Commerce Engine uses the engines that implement Parties, Products and Orders, and adds the ability to conduct commerce."
  s.description = "The CompassAE Commerce Engine uses the engines that implement Parties, Products and Orders, and adds the ability to conduct commerce. It implements a pricing engine, fees, payment gateways."
  s.authors     = ["Rick Koloski, Russell Holmes"]
  s.email       = ["russonrails@gmail.com"]
  s.homepage    = "http://development.compassagile.com"

  s.license = 'GPL-3'
  s.files = Dir["{app,config,db,lib,tasks,public}/**/*"] + ["GPL-3-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "activemerchant", "1.49.0"

  #compass_ae dependencies
  s.add_dependency "erp_orders", "~> 4.2"
  s.add_development_dependency "erp_dev_svcs", "~> 4.2"
end
