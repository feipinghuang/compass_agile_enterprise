require 'has_many_polymorphic'
require 'attr_encrypted'
require 'awesome_nested_set'
require 'data_migrator'
require 'acts_as_list'

module ErpBaseErpSvcs
  class Engine < Rails::Engine
    isolate_namespace ErpBaseErpSvcs

    Mime::Type.register "tree", :tree

    config.erp_base_erp_svcs = ErpBaseErpSvcs::Config

    initializer "erp_base_erp_svcs.merge_public" do |app|
      app.middleware.insert_before Rack::Runtime, ::ActionDispatch::Static, "#{root}/public"
    end

    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    ActiveSupport.on_load(:active_record) do
      include ErpBaseErpSvcs::Extensions::ActiveRecord::IsDescribable
      include ErpBaseErpSvcs::Extensions::ActiveRecord::HasNotes
      include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsNoteType
      include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsErpType
      include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsCategory
      include ErpBaseErpSvcs::Extensions::ActiveRecord::IsContactMechanism
      include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsFixedAsset
      include ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsFacility
      include ErpBaseErpSvcs::Extensions::ActiveRecord::CanBeGenerated
      include ErpBaseErpSvcs::Extensions::ActiveRecord::HasPartyRoles
      include ErpBaseErpSvcs::Extensions::ActiveRecord::HasContacts
      include ErpBaseErpSvcs::Extensions::ActiveRecord::TracksCreatedByUpdatedBy
      include ErpBaseErpSvcs::Extensions::ActiveRecord::IsTenantable
      extend ErpBaseErpSvcs::Extensions::ActiveRecord::StiInstantiation::ActMacro
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)

  end
end
