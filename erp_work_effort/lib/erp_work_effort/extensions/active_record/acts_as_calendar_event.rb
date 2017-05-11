module ErpWorkEffort
  module Extensions
    module ActiveRecord
      module ActsAsCalendarEvent

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_calendar_event
            extend ActsAsCalendarEvent::SingletonMethods
            include ActsAsCalendarEvent::InstanceMethods

            attr_accessible :start, :end, :title
            is_tenantable
            is_repeatable :starttime, :endtime

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