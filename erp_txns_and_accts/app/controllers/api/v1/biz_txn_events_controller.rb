module Api
  module V1
    class BizTxnEventsController < BaseController

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0
        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        biz_txn_events = BizTxnEvent

        # hook method to apply any scopes passed via parameters to this api
        biz_txn_events = biz_txn_events.apply_filters(query_filter, biz_txn_events)

        # scope by dba_organizations if there are no parties passed as filters
        unless query_filter[:parties]
          dba_organizations = [current_user.party.dba_organization]
          dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
          biz_txn_events = biz_txn_events.scope_by_dba_organization(dba_organizations)
        end

        biz_txn_events = biz_txn_events.order("#{sort} #{dir}")

        total_count = biz_txn_events.count
        biz_txn_events = biz_txn_events.offset(start).limit(limit)

        render :json => {total_count: total_count, biz_txn_events: biz_txn_events.collect(&:to_data_hash)}
      end

      def show
        biz_txn_event = BizTxnEvent.find(params[:id])

        render :json => {biz_txn_event: biz_txn_event.to_data_hash}
      end


    end # BizTxnEvents
  end # V1
end # Api