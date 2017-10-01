module ErpInventory
  class Engine < Rails::Engine
    isolate_namespace ErpInventory

    initializer "erp_base_erp_svcs.merge_public" do |app|
      app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end

    ActiveSupport.on_load(:active_record) do
      include ErpInventory::Extensions::ActiveRecord::ActsAsInventoryEntry
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)

  end
end
