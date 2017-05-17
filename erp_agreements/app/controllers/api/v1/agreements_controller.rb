module API
  module V1
    class AgreementsController < BaseController

=begin
  @api {get} /api/v1/agreements Index
  @apiVersion 1.0.0
  @apiName GetAgreements
  @apiGroup Agreement
  @apiDescription Get Agreements
  
  @apiSuccess (200) {Object} get_agreements Response.
  @apiSuccess (200) {Boolean} get_agreements.success True if the request was successful.
  @apiSuccess (200) {Integer} get_agreements.total_count Total count of records
  @apiSuccess (200) {Object[]} get_agreements.agreements
  @apiSuccess (200) {Number} get_agreements.agreements.id Id.
  @apiSuccess (200) {String} get_agreements.agreements.description Description.
  @apiSuccess (200) {String} get_agreements.agreements.agreement_status Status of Agreement.
  @apiSuccess (200) {Date} get_agreements.agreements.agreement_date Agreement Date.
  @apiSuccess (200) {Date} get_agreements.agreements.from_date From Date.
  @apiSuccess (200) {Date} get_agreements.agreements.thru_date Thru Date.
  @apiSuccess (200) {String} get_agreements.agreements.external_identifier External Identifier.
  @apiSuccess (200) {String} get_agreements.agreements.external_id_source External Id Source.
=end

      def index
        agreements = Agreement.by_tenant(current_user.party.dba_organization)

        if params[:party_id]
          @query_filter[:party] = params[:party_id]
        end

        if params[:role_types]
          @query_filter[:role_types] = params[:role_types]
        end

        agreements = agreements.apply_filters(@query_filter)

        total_count = agreements.count

        agreements = agreements.offset(@offset).limit(@limit)

        render json: {success: true, total_count: total_count, agreements: agreements.collect(&:to_data_hash)}
      end

    end # AgreementsController
  end # V1
end # API
