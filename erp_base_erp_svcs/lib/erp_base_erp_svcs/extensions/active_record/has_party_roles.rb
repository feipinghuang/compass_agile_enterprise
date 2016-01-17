module ErpBaseErpSvcs
  module Extensions
    module ActiveRecord
      module HasPartyRoles
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def has_party_roles
            extend HasPartyRoles::SingletonMethods
            include HasPartyRoles::InstanceMethods

            has_many :entity_party_roles, :as => :entity_record, dependent: :destroy
            has_many :role_types, :through => :entity_party_roles
          end
        end

        module SingletonMethods
          def with_party_role_types(role_types)
            joins(:entity_party_roles)
                .where("entity_party_roles.role_type_id in (#{role_types.collect(&:id).join(',')})")
          end

          def with_party_role(party, role_type)
            joins(:entity_party_roles).where('entity_party_roles.role_type_id = ?', role_type.id)
                .where('entity_party_roles.party_id = ?', party.id)
          end
        end

        module InstanceMethods
          def add_party_with_role(party, role_type)
            entity_party_role = EntityPartyRole.where(party_id: party,
                                                      role_type_id: role_type,
                                                      entity_record_id: self.id,
                                                      entity_record_type: self.class.name).first

            unless entity_party_role
              entity_party_role = EntityPartyRole.create(party: party,
                                                         role_type: role_type,
                                                         entity_record: self)
            end

            entity_party_role
          end

          def remove_party_with_role(party, role_type)
            entity_party_role = EntityPartyRole.where(party_id: party,
                                                      role_type_id: role_type,
                                                      entity_record_id: self.id,
                                                      entity_record_type: self.class.name).first

            if entity_party_role
              entity_party_role.destroy
            end
          end

          def find_parties_by_role(role_type)
            if role_type.is_a?(String)
              role_type = RoleType.iid(role_type)
            end

            entity_party_roles.where(role_type_id: role_type.id).collect(&:party)
          end

          def find_party_with_role(role_type)
            if role_type.is_a?(String)
              role_type = RoleType.iid(role_type)
            end

            entity_party_role = entity_party_roles.where(role_type_id: role_type.id).first

            if entity_party_role
              entity_party_role.party
            else
              nil
            end
          end
        end

      end # HasPartyRoles
    end # ActiveRecord
  end # Extensions
end # ErpBaseErpSvcs
