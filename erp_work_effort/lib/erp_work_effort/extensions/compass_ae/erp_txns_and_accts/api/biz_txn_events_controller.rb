module Api
  module V1
    module Extensions
      module BizTxnEventsController

        protected

        # hook method to apply any scopes passed via parameters to this API Controller
        #
        # @param statement [ActiveRecord::Relation] relation query being built for the record accessed via
        # this API
        # @return [ActiveRecord::Relation]
        def apply_scopes(biz_txn_events)
          biz_txn_events = super(biz_txn_events)

          if params[:work_effort_id]
            biz_txn_events = biz_txn_events.joins(:work_effort_biz_txn_events)
                                 .where('work_effort_biz_txn_events.work_effort_id' => params[:work_effort_id])
          end

          biz_txn_events
        end

      end # BizTxnEventsController
    end # Extensions
  end # V1
end # Api

Api::V1::BizTxnEventsController.class_eval do
  prepend Api::V1::Extensions::BizTxnEventsController
end