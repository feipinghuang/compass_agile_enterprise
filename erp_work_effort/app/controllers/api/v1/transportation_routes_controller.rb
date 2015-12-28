module Api
  module V1
    class TransportationRoutesController < BaseController

      # Start TransportationRoute by creating a TransportationRouteSegment and
      # setting the actual start and comments if passed
      # If a WorkEffort id is passed it will be associated to that WorkEffort
      #
      #
      def start
        begin
          ActiveRecord::Base.connection.transaction do

            party = current_user.party

            # check for an open TransportationRoute
            open_transportation_route = party.transportation_routes.open.first

            # if there is an open TransportationRoute stop it and start a new one
            if open_transportation_route
              segment = open_transportation_route.segements.last
              segment.actual_arrival = Time.now.utc

              segment.calculate_miles_traveled!
            end

            transportation_route = TransportationRoute.create(
                description: params[:description].present? ? params[:description].strip : nil
            )
            # create a segment for this TransportationRoute
            TransportationRouteSegment.create(
                route: transportation_route,
                actual_start: Time.now.utc,
                comments: params[:comment].present? ? params[:comment].strip : nil
            )
            transportation_route.add_party_with_role(party, RoleType.iid('work_resource'))

            if params[:work_effort_id]
              relationship = AssociatedTransportationRoute.new
              relationship.transportation_route = transportation_route
              relationship.associated_record = WorkEffort.find(params[:work_effort_id])
              relationship.save!
            end

            render json: {
                       success: true,
                       transportation_route: transportation_route.to_data_hash,
                   }
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error starting Trip'}
        end
      end

      # Stop TransportationRoute by setting the actual_arrival of the segment and calculating the miles traveled
      #
      def stop
        begin
          ActiveRecord::Base.connection.transaction do
            transportation_route = TransportationRoute.find(params[:id])

            transportation_route.description = params[:description].present? ? params[:description].strip : nil
            transportation_route.save!

            segment = transportation_route.segments.last

            segment.actual_arrival = Time.strptime(params[:end_at], "%Y-%m-%dT%H:%M:%S%z").in_time_zone.utc
            segment.comments = params[:comment].present? ? params[:comment].strip : nil
            segment.save!

            segment.calculate_miles_traveled!

            result = {
                success: true,
                transportation_route: transportation_route.to_data_hash,
            }

            render json: result
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Error stopping Time Entry'}
        end
      end

      # If a WorkEffort id is passed it gets any open TransportationRoutes for that WorkEffort
      # or any open for the current user if no WorkEffort is Passed
      #
      def open
        party = current_user.party

        if params[:work_effort_id]
          work_effort = WorkEffort.find(params[:work_effort_id])

          open_transportation_route = work_effort.transportation_routes.scope_by_party(current_user.party).open.first
        else
          open_transportation_route = party.transportation_routes.open.first
        end

        render :json => {success: true,
                         transportation_route: open_transportation_route.nil? ? nil : open_transportation_route.to_data_hash}
      end

    end # TransportationRoutesController
  end # V1
end # Api