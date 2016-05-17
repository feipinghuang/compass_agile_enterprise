module ErpTechSvcs
  module Extensions
    module ActiveRecord
      module HasCapabilityAccessors

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def has_capability_accessors
            extend HasCapabilityAccessors::SingletonMethods
            include HasCapabilityAccessors::InstanceMethods

            has_many :capability_accessors, :as => :capability_accessor_record
          end
        end

        module SingletonMethods
        end

        module InstanceMethods

          # method to get capabilities this instance does NOT have
          def capabilities_not
            Capability.joins(:capability_type).
              joins("LEFT JOIN capability_accessors ON capability_accessors.capability_id = capabilities.id AND capability_accessors.capability_accessor_record_type = '#{self.class.name}' AND capability_accessors.capability_accessor_record_id = #{self.id}").
              where("capability_accessors.id IS NULL")
          end

          def scope_capabilities_not(scope_type_iid)
            scope_type = ScopeType.find_by_internal_identifier(scope_type_iid)
            capabilities_not.where(:scope_type_id => scope_type.id)
          end

          # method to get only class capabilities this instance does NOT have
          def class_capabilities_not
            scope_capabilities_not('class')
          end

          def query_capabilities_not
            scope_capabilities_not('query')
          end

          def capabilities
            Capability.joins(:capability_type).joins(:capability_accessors).
              where(:capability_accessors => { :capability_accessor_record_type => self.class.name, :capability_accessor_record_id => self.id })
          end

          def scope_capabilities(scope_type_iid)
            scope_type = ScopeType.find_by_internal_identifier(scope_type_iid)
            capabilities.where(:scope_type_id => scope_type.id)
          end

          # method to get all capabilities for this model
          def all_capabilities
            capabilities
          end

          # method to get only class capabilities for this model
          def class_capabilities
            scope_capabilities('class')
          end

          # method to get only query capabilities for this model
          def query_capabilities
            scope_capabilities('query')
          end

          # method to get only instance capabilities for this model
          def instance_capabilities
            scope_capabilities('instance')
          end

          def get_or_create_capability(capability_type_iid, klass)
            capability_type = convert_capability_type(capability_type_iid)
            if klass.is_a?(String)
              scope_type = ScopeType.find_by_internal_identifier('class')
              Capability.find_or_create_by_capability_resource_type_and_capability_type_id_and_scope_type_id(klass, capability_type.id, scope_type.id)
            else
              klass.add_capability(capability_type_iid) # create instance capability
            end
          end

          def get_capability(capability_type_iid, klass)
            capability_type = convert_capability_type(capability_type_iid)
            scope_type = ScopeType.find_by_internal_identifier('class')
            Capability.find_by_capability_resource_type_and_capability_type_id_and_scope_type_id(klass, capability_type.id, scope_type.id)
          end

          def has_capabilities?
            !capability_accessors.empty?
          end

          # Add multiple capabilities
          #
          # @param _capabilities [Array] Array of Capbilities
          def add_capabilities(_capabilities)
            _capabilities.each do |capability|
              add_capability(capability)
            end
          end

          alias :grant_capabilities :add_capabilities

          # pass in (capability_type_iid, klass) or (capability) object
          def add_capability(*capability)
            capability_type_iid = capability.first.is_a?(Symbol) ? capability.first.to_s : capability.first
            capability = capability_type_iid.is_a?(String) ? get_or_create_capability(capability_type_iid, capability.second) : capability.first
            ca = CapabilityAccessor.find_or_create_by_capability_accessor_record_type_and_capability_accessor_record_id_and_capability_id(get_superclass, self.id, capability.id)
            self.reload
            ca
          end

          alias :grant_capability :add_capability

          # pass in (capability_type_iid, klass) or (capability) object
          def remove_capability(*capability)
            capability_type_iid = capability.first.is_a?(Symbol) ? capability.first.to_s : capability.first
            capability = capability_type_iid.is_a?(String) ? get_or_create_capability(capability_type_iid, capability.second) : capability.first
            ca = capability_accessors.where(:capability_accessor_record_type => get_superclass, :capability_accessor_record_id => self.id, :capability_id => capability.id).first
            ca.destroy unless ca.nil?
            self.reload
            ca
          end

          alias :revoke_capability :remove_capability

          # Remove multiple capabilities
          #
          # @param _capabilities [Array] Array of Capbilities
          def remove_capabilities(_capabilities)
            _capabilities.each do |capability|
              remove_capability(capability)
            end
          end

          alias :revoke_capabilities :remove_capabilities

          # Remove all current capabilities
          #
          def remove_all_capabilities
            capabilities.each do |capability|
              remove_capability(capability)
            end
          end

          alias :revoke_all_capabilities :remove_all_capabilities

          private

          def convert_capability_type(type)
            return type if type.is_a?(CapabilityType)
            return nil unless (type.is_a?(String) || type.is_a?(Symbol))
            ct = CapabilityType.find_by_internal_identifier(type.to_s)
            return ct unless ct.nil?
            CapabilityType.create(:internal_identifier => type.to_s, :description => type.to_s.titleize)
          end
        end

      end # HasCapabilityAccessors
    end # ActiveRecord
  end # Extensions
end # ErpTechSvcs
