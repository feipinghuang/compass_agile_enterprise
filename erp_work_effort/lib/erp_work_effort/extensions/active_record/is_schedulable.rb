module ErpWorkEffort
  module Extensions
    module ActiveRecord
      module IsSchedulable

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def is_schedulable
            extend IsSchedulable::SingletonMethods
            include IsSchedulable::InstanceMethods

            attr_accessor :starttime, :endtime, :title
            is_repeatable :starttime, :endtime
            is_tenantable

            validate :starttime_before_endtime
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def starttime_before_endtime
            if starttime > endtime
              errors.add(:starttime, 'must be before endtime.')
            end
          end
        end
      end
    end
  end
end