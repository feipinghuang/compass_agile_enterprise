module ErpBaseErpSvcs
  module Helpers
    module Time

      class Client

        def initialize(client_utc_offset)
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

        protected

        def get_offset_in_hours(client_utc_offset=nil)
          if client_utc_offset.nil?
            zone = Rails.configuration.time_zone

            zone.utc_offset / 60 / 100
          else
            client_utc_offset = client_utc_offset.to_i
            hours = client_utc_offset / 60

            if hours < 0
              hours = "+#{hours}"

            else
              hours = "-#{hours}"
            end

            hours.to_i
          end
        end

      end

    end # Time
  end # Helpers
end # ErpBaseErpSvcs