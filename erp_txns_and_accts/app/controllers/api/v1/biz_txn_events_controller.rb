module Api
  module V1
    class BizTxnEventsController < BaseController

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0

        biz_txn_events = BizTxnEvent

        # hook method to apply any scopes passed via parameters to this api
        biz_txn_events = apply_scopes(biz_txn_events)

        biz_txn_events = biz_txn_events.order("#{sort} #{dir}")

        total_count = biz_txn_events.count
        biz_txn_events = biz_txn_events.offset(start).limit(limit)

        render :json => {total_count: total_count, biz_txn_events: biz_txn_events.collect(&:to_data_hash)}
      end

      def show
        biz_txn_event = BizTxnEvent.find(params[:id])

        render :json => {biz_txn_event: biz_txn_event.to_data_hash}
      end

      protected

      # hook method to apply any scopes passed via parameters to this API Controller
      #
      # @param statement [ActiveRecord::Relation] relation query being built for the record accessed via
      # this API
      # @return [ActiveRecord::Relation]
      def apply_scopes(biz_txn_events)
        # scope by dba_organization
        biz_txn_events = biz_txn_events.scope_by_dba_organization(current_user.party.dba_organization)

        if params[:query]
          biz_txn_events = biz_txn_events.where('description like ?', "%#{params[:query].strip}%")
        end

        if params[:biz_txn_types]
          biz_txn_events = biz_txn_events.where('biz_txn_type_id' => BizTxnType.where(internal_identifier: params[:biz_txn_types].split(',')))
        end

        biz_txn_events
      end


    end # BizTxnEvents
  end # V1
end # Api