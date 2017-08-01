module ErpBaseErpSvcs
  module Helpers
    module Time

      class Client

        def initialize(client_utc_offset=nil)
          @offset_in_hours = get_offset_in_hours(client_utc_offset)
        end

        def in_client_time(time)
          time + @offset_in_hours.hours
        end

        def client_to_utc_time(time)
          time - @offset_in_hours.hours
        end

        def beginning_of_day
          (::Time.now  + @offset_in_hours.hours).beginning_of_day
        end

        def end_of_day
          (::Time.now  + @offset_in_hours.hours).end_of_day
        end

        def beginning_of_week
          (::Time.now  + @offset_in_hours.hours).beginning_of_week
        end

        def end_of_week
          (::Time.now  + @offset_in_hours.hours).end_of_week
        end

        # Finds the correspoding time in UTC combining the date and time passed separately
        def in_utc_time(date, time)
          parsed_date = (Time.parse(date)) - @offset_in_hours.hours
          parsed_time = Time.parse(time)
          datetime_in_utc = parsed_date.change(hour: parsed_time.hour, min: parsed_time.min) + @offset_in_hours.hours
          Time.zone.local_to_utc (datetime_in_utc)
        end

        protected

        def get_offset_in_hours(client_utc_offset=nil)
          if client_utc_offset.nil?
            offset = ::Time.now.formatted_offset
            if offset.is_a? Integer
              offset/60.0
            else
              hours_and_minutes = offset.split(':').map(&:to_f)
              hours_and_minutes[0] + hours_and_minutes[1]/60
            end
          else
            client_utc_offset = client_utc_offset.to_i
            hours = client_utc_offset / 60.0
            -hours
          end
        end

      end

    end # Time
  end # Helpers
end # ErpBaseErpSvcs