module ErpBaseErpSvcs
  module Extensions
    module ActiveRecord
      module IsTenantable
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def is_tenantable
            extend IsTenantable::SingletonMethods
            include IsTenantable::InstanceMethods

            belongs_to :tenant, class_name: 'Party'
          end
        end # ClassMethods

        module SingletonMethods

          def by_tenant(tenant)
            where(tenant_id: tenant)
          end

        end # SingletonMethods

        module InstanceMethods

          def set_tenant!(_tenant)
            self.tenant = _tenant
            save!
          end

        end # InstanceMethods

      end # IsTenantable
    end # ActiveRecord
  end # Extensions
end # ErpBaseErpSvcs

ActiveRecord::Base.instance_eval do
  def is_tenantable?
    self.eigenclass.included_modules.include?(::ErpBaseErpSvcs::Extensions::ActiveRecord::IsTenantable::SingletonMethods)
  end
end
