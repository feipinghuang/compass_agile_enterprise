require 'has_many_polymorphic'
require 'attr_encrypted'
require 'awesome_nested_set'
require 'data_migrator'

module ErpBaseErpSvcs
  class Engine < Rails::Engine
    isolate_namespace ErpBaseErpSvcs

    Mime::Type.register "tree", :tree

    config.erp_base_erp_svcs = ErpBaseErpSvcs::Config

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
      extend ErpBaseErpSvcs::Extensions::ActiveRecord::StiInstantiation::ActMacro
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)

  end
end
