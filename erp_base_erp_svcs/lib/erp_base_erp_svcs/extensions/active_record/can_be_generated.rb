module ErpBaseErpSvcs
  module Extensions
    module ActiveRecord
      module CanBeGenerated
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def can_be_generated
            extend CanBeGenerated::SingletonMethods
            include CanBeGenerated::InstanceMethods

            has_many :generated_items, :as => :generated_record
          end
        end # ClassMethods

        module SingletonMethods

          def items_generated_by(record)
            entity_record_type = (record.class.superclass == ::ActiveRecord::Base) ? record.class.name.to_s : record.class.superclass.to_s

            joins(:generated_items)
                .where('generated_items.generated_by_type = ?', entity_record_type)
                .where('generated_items.generated_by_id = ?', record.id)
          end

        end # SingletonMethods

        module InstanceMethods
          def generated_by
            if generated_items.length == 1
              generated_items.first.generated_by
            else
              generated_items.collect(&:generated_by)
            end
          end

          def generated_by=(record)
            if record.is_a?(Array)
              record.each do |item|
                GeneratedItem.create(generated_record: self, generated_by: item)
              end
            else
              GeneratedItem.create(generated_record: self, generated_by: record)
            end
          end

        end # InstanceMethods

      end # CanBeGenerated
    end # ActiveRecord
  end # Extensions
end # ErpBaseErpSvcs
