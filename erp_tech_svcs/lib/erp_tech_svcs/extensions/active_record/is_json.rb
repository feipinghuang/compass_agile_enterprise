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

            before_update "#{attr_name}_check_dirty".to_sym

            extend SingletonMethods
            include InstanceMethods

            # create method to initialize the json field with an empty hash
            define_method("initialize_#{attr_name}_json") do
              if attributes.keys.include?(attr_name.to_s) && send("#{attr_name}").nil?
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

            define_method("#{attr_name}_dirty?") do
              _db_record = self.class.where("#{attr_name} = ?", self.send(attr_name).to_json).first

              _db_record.nil?
            end

            define_method("#{attr_name}_check_dirty") do
              self.send("#{attr_name}_will_change!") if self.send("#{attr_name}_dirty?")
            end
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
          alias :with_json_attr :with_json_attribute
        end

        module InstanceMethods
        end

      end # IsJson
    end # ActiveRecord
  end # Extensions
end # ErpTechSvcs

