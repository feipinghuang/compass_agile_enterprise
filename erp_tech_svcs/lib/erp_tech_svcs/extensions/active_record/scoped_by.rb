module ErpTechSvcs
  module Extensions
    module ActiveRecord
      module ScopedBy

        module Errors
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        def _config
          @config
        end

        module ClassMethods

          def add_scoped_by(attr_name=:scoped_by)
            # serialize Scope attributes
            is_json attr_name

            extend SingletonMethods
            include InstanceMethods

            # create method to retrieve scoped_by attribute name
            define_singleton_method("retrieve_scoped_by_name") do
              attr_name
            end

            # create method to initialize the json field with an empty hash
            define_method("initialize_#{attr_name}_scoped_by_json") do
              if self.new_record?
                send("#{attr_name}=", {})
              end
            end
            after_initialize "initialize_#{attr_name}_scoped_by_json"
          end

        end

        module SingletonMethods
          def scoped_by(scope_name, scope_value)
            where(arel_table[retrieve_scoped_by_name].matches("%\"#{scope_name}\":\"#{scope_value}\"%").or(arel_table[retrieve_scoped_by_name].matches("%\"#{scope_name}\":#{scope_value}%")))
          end
        end

        module InstanceMethods
          def add_scope(scope_name, scope_value)
            send(self.class.retrieve_scoped_by_name)[scope_name.to_s] = scope_value
            save!
          end

          def remove_scope(scope_name)
            send(self.class.retrieve_scoped_by_name)[scope_name.to_s] = nil
            save!
          end

          def get_scope(scope_name)
            send(self.class.retrieve_scoped_by_name)[scope_name.to_s]
          end
        end

      end # ScopedBy
    end # ActiveRecord
  end # Extensions
end # ErpTechSvcs
