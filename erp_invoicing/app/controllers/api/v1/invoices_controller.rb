module Api
  module V1
    class InvoicesController < BaseController

      def index
        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        invoices = Invoice.apply_filters(query_filter)

        # scope by dba organization
        invoices = invoices.joins("inner join invoice_party_roles as invoice_party_reln on
                          (invoice_party_reln.invoice_id = invoices.id
                          and
                          invoice_party_reln.party_id in (#{current_user.party.dba_organization.id})
                          and
                          invoice_party_reln.role_type_id = #{RoleType.iid('dba_org').id}
                          )")

        total_count = invoices.count

        render json: {total_count: total_count, invoices: invoices.collect{|invoice| invoice.to_data_hash} }
      end

    end # InvoicesController
  end # V1
end # Api
