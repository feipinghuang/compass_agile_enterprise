module ErpBaseErpSvcs
  module Helpers
    module Time

      class Client

        def initialize(client_utc_offset)
          @time_zone = get_time_zone(client_utc_offset)
        end

        def in_client_time(time)
          time.in_time_zone(@time_zone)
        end

        def beginning_of_day
          ::Time.now.in_time_zone(@time_zone).beginning_of_day
        end

        def end_of_day
          ::Time.now.in_time_zone(@time_zone).end_of_day
        end

        def beginning_of_week
          ::Time.now.in_time_zone(@time_zone).beginning_of_week
        end

        def end_of_week
          ::Time.now.in_time_zone(@time_zone).end_of_week
        end

        protected

        def get_time_zone(client_utc_offset=nil)
          if client_utc_offset.nil?
            Rails.configuration.time_zone
          else
            client_utc_offset = client_utc_offset.to_i
            hours = client_utc_offset / 60

            if hours < 10
              client_utc_offset = "0#{hours}"
            else
              client_utc_offset = hours
            end

            if hours < 0
              client_utc_offset = "+#{client_utc_offset}"

            else
              client_utc_offset = "-#{client_utc_offset}"
            end

            ActiveSupport::TimeZone[client_utc_offset.to_i]
          end
        end

      end

    end # Time
  end # Helpers
end # ErpBaseErpSvcs