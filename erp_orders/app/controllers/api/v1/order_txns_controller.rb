module Api
  module V1
    class OrderTxnsController < BaseController

      def index
        sort = nil
        dir = nil
        limit = nil
        start = nil

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'description'
          dir = sort_hash[:direction] || 'ASC'
          limit = params[:limit] || 25
          start = params[:start] || 0
        end

        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys
        context = params[:context].blank? ? {} : JSON.parse(params[:context]).symbolize_keys

        # hook method to apply any scopes passed via parameters to this api
        order_txns = OrderTxn.apply_filters(query_filter)

        # scope by dba_organizations if there are no parties passed as filters
        unless query_filter[:user_id]
          dba_organizations = [current_user.party.dba_organization]
          dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
          order_txns = order_txns.scope_by_dba_organization(dba_organizations)
        end

        if sort and dir
          order_txns = order_txns.order("#{sort} #{dir}")
        else
          order_txns = order_txns.order("id desc")
        end

        total_count = order_txns.count

        if start and limit
          order_txns = order_txns.offset(start).limit(limit)
        end

        if context[:view]
          if context[:view] == 'mobile'
            render :json => {success: true,
                             total_count: total_count,
                             order_txns: order_txns.collect { |order_txn| order_txn.to_mobile_hash }}
          end
        else
          render :json => {success: true,
                           total_count: total_count,
                           order_txns: order_txns.collect { |order_txn| order_txn.to_data_hash }}
        end

      end

      def show
        order_txn = OrderTxn.find(params[:id])

        render :json => {success: true,
                         order_txn: order_txn.to_data_hash}
      end

      def destroy
        OrderTxn.find(params[:id]).destroy

        render :json => {:success => true}
      end

    end # OrderTxnsController
  end # V1
end # Api