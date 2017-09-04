module ErpTechSvcs
  class Engine < Rails::Engine
    config.erp_tech_svcs = ErpTechSvcs::Config

    isolate_namespace ErpTechSvcs

    ActiveSupport.on_load(:active_record) do
      include ErpTechSvcs::Extensions::ActiveRecord::HasSecurityRoles
      include ErpTechSvcs::Extensions::ActiveRecord::HasFileAssets
      include ErpTechSvcs::Extensions::ActiveRecord::ProtectedByCapabilities
      include ErpTechSvcs::Extensions::ActiveRecord::HasCapabilityAccessors
      include ErpTechSvcs::Extensions::ActiveRecord::IsJson
      include ErpTechSvcs::Extensions::ActiveRecord::ScopedBy
    end

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)

  end
end
