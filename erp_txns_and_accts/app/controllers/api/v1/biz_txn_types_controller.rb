module Api
  module V1
    class BizTxnTypesController < BaseController

      def index
        if params[:parent]
          parent = nil
          # create parent if it doesn't exist
          # if the parent param is a comma separated string then
          # the parent is nested from left to right
          params[:parent].split(',').each do |parent_iid|
            if parent
              parent = BizTxnType.find_or_create(parent_iid, parent_iid.humanize, parent)
            else
              parent = BizTxnType.find_or_create(parent_iid, parent_iid.humanize)
            end
          end
          biz_txn_types = parent.children.all.collect { |txn_type| txn_type.to_data_hash }
        else
          biz_txn_types = BizTxnType.all.collect { |txn_type| txn_type.to_data_hash }
        end

        render :json => {success: true, biz_txn_types: biz_txn_types}
      end

    end # BizTxnTypesController
  end # V1
end # Api