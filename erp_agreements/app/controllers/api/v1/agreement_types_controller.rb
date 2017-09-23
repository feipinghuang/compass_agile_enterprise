module API
  module V1
    class AgreementTypesController < BaseController

=begin
  @api {get} /api/v1/agreement_types Index
  @apiVersion 1.0.0
  @apiName GetAgreementTypes
  @apiGroup AgreementType
  @apiDescription Get Agreement Types
  
  @apiSuccess (200) {Object} get_agreement_types Response.
  @apiSuccess (200) {Boolean} get_agreement_types.success True if the request was successful.
  @apiSuccess (200) {Integer} get_agreement_types.total_count Total count of records
  @apiSuccess (200) {Object[]} get_agreement_types.agreement_types
  @apiSuccess (200) {Number} get_agreement_types.agreement_types.id Id.
  @apiSuccess (200) {String} get_agreement_types.agreement_types.description Description.
  @apiSuccess (200) {String} get_agreement_types.agreement_types.internal_identifier Internal Identifier.
  @apiSuccess (200) {String} get_agreement_types.agreement_types.external_identifier External Identifier.
  @apiSuccess (200) {String} get_agreement_types.agreement_types.external_id_source External Id Source.
=end

      def index
      	agreement_types = AgreementType.by_tenant(current_user.party.dba_organization)

      	total_count = agreement_types.count

      	agreement_types = agreement_types.offset(@offset).limit(@limit)

      	render json: {success: true, total_count: total_count, agreement_types: agreement_types.collect(&:to_data_hash)}
      end

    end # AgreementTypesController
  end # V1
end # API
