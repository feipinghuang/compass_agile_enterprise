module ErpTxnsAndAccts
  class Engine < Rails::Engine
    isolate_namespace ErpTxnsAndAccts

    initializer "erp_base_erp_svcs.merge_public" do |app|
      app.middleware.insert_before Rack::Runtime, ::ActionDispatch::Static, "#{root}/public"
    end

    ActiveSupport.on_load(:active_record) do
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsBizTxnAccount
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsBizTxnEvent
      include ErpTxnsAndAccts::Extensions::ActiveRecord::ActsAsFinancialTxnAccount
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)

  end
end
