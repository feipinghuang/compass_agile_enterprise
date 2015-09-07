module Api
  module V1
    class BizTxnEventsController < BaseController

      def index
        query = params[:query]
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0
        biz_txn_types = params[:biz_txn_types]

        biz_txn_events = BizTxnEvent

        unless query.blank?
          biz_txn_events = biz_txn_events.where('description like ?', "%#{query}%")
        end

        unless biz_txn_types.blank?
          biz_txn_events = biz_txn_events.where('biz_txn_type_id' => BizTxnType.where(internal_identifier: biz_txn_types.split(',')))
        end

        # scope by dba_organization
        biz_txn_events = biz_txn_events.with_dba_organization(current_user.party.dba_organization)

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