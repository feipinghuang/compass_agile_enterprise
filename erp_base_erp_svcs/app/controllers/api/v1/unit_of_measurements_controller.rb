module Api
  module V1
    class UnitOfMeasurementsController < BaseController

      def index
        render json: {
                   unit_of_measurements:
                       UnitOfMeasurement.scope_by_dba_organization(current_user.party.dba_organization).collect do |uom|
                         uom.to_data_hash
                       end
               }
      end

    end # UnitOfMeasurementsController
  end # V1
end # Api