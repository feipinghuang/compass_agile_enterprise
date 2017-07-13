module API
  module V1
    class ContactPurposesController < BaseController

=begin
 @api {get} /api/v1/contact_purposes
 @apiVersion 1.0.0
 @apiName GetContactPurposes
 @apiGroup ContactPurpose
 @apiDescription Get Contact Purposes
 
 @apiParam (query) {Integer[]} [ids] Array of ids to filter by

 @apiSuccess (200) {Object} get_contact_purposes_response Response.
 @apiSuccess (200) {Boolean} get_contact_purposes_response.success True if the request was successful.
 @apiSuccess (200) {Number} get_contact_purposes_response.total_count Total count of records based on any filters applied.
 @apiSuccess (200) {Object[]} get_contact_purposes_response.contact_purposes List of ContactPurpose records.
 @apiSuccess (200) {Number} get_contact_purposes_response.contact_purposes.id Id of ContactPurpose.
=end

      def index
        contact_purposes = if params[:ids].present?
          [ContactPurpose.where(id: params[:ids])]
        else
          ContactPurpose.all
        end

        render json: {success: true,
                      contact_purposes: contact_purposes.collect(&:to_data_hash)}
      end

      def show
        contact_purpose = ContactPurpose.find(params[:id])

        render json: {success: true, contact_purpose: contact_purpose.to_data_hash}
      end

    end # ContactPurposesController
  end # V1
end # API
