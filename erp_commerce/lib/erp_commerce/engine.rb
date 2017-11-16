module ErpCommerce
  class Engine < Rails::Engine
    isolate_namespace ErpCommerce

    config.erp_commerce = ErpCommerce::Config

    initializer "erp_base_erp_svcs.merge_public" do |app|
      app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end

    ActiveSupport.on_load(:active_record) do
      include ErpCommerce::Extensions::ActiveRecord::ActsAsFee
      include ErpCommerce::Extensions::ActiveRecord::ActsAsPriceable
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)
    ::ErpApp::Widgets::Loader.load_compass_ae_widgets(config, self)

  end#Engine
end#ErpCommerce
