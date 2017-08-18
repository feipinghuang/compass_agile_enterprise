module ErpBaseErpSvcs
  module Extensions
    module ActiveRecord
      module TracksCreatedByUpdatedBy

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def tracks_created_by_updated_by
            belongs_to :created_by_party, class_name: Party

            belongs_to :updated_by_party, class_name: Party

            include InstanceMethods
          end
        end

        module InstanceMethods
          def created_by
            created_by_party
          end

          def updated_by
            updated_by_party
          end
        end

      end # TracksCreatedByUpdatedBy
    end # ActiveRecord
  end # Extensions
end # ErpBaseErpSvcs
