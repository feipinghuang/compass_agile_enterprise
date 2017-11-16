module ErpWorkEffort
  class Engine < Rails::Engine
    isolate_namespace ErpWorkEffort

    initializer "erp_work_effort.merge_public" do |app|
      app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end

    ActiveSupport.on_load(:active_record) do
      include ErpWorkEffort::Extensions::ActiveRecord::IsSchedulable
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsWorkEffort
      include ErpWorkEffort::Extensions::ActiveRecord::ActsAsRoutable
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)

  end
end
