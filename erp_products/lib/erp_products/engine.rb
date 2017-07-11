module ErpProducts
  class Engine < Rails::Engine
    isolate_namespace ErpProducts

    initializer "erp_products.merge_public" do |app|
      app.middleware.insert_before Rack::Runtime, ::ActionDispatch::Static, "#{root}/public"
    end

    ActiveSupport.on_load(:active_record) do
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductInstance
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductOffer
      include ErpProducts::Extensions::ActiveRecord::ActsAsProductType
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)
  end
end
