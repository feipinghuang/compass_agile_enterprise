module ErpTechSvcs
  module Extensions
    module ActiveRecord
      module IsJson

        module Errors

        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def is_json(attr_name)
            serialize attr_name, JSON

            extend SingletonMethods
            include InstanceMethods

            # create method to initialize the json field with an empty hash
            define_method("initialize_#{attr_name}_json") do
              if send("#{attr_name}").nil?
                send("#{attr_name}=", {})
              end
            end
            after_initialize "initialize_#{attr_name}_json"

            define_method("stringify_keys_for_#{attr_name}_json") do
              if send(attr_name).is_a?(Hash)
                send("#{attr_name}=", send(attr_name).stringify_keys)
              end
            end
            before_save "stringify_keys_for_#{attr_name}_json".to_sym
          end

        end

        module SingletonMethods
          def matches_is_json(attr_name, keyword, attr=nil)
            if attr
              arel_table[attr_name.to_sym].matches("%\"#{attr}\":\"#{keyword}\"%").
                  or(arel_table[attr_name.to_sym].matches("%\"#{attr}\":#{keyword}%"))
            else
              arel_table[attr_name.to_sym].matches("%#{keyword}%")
            end
          end

          def with_json_attribute(attr_name, attr, keyword)
            where(self.matches_is_json(attr_name, keyword, attr))
          end
        end

        module InstanceMethods
        end

      end # IsJson
    end # ActiveRecord
  end # Extensions
end # ErpTechSvcs

