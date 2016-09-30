OrderTxn.class_eval do

  before_destroy :destroy_work_items

  def destroy_work_items
    # if this is a work order then we should destroy any related tasks
    if BizTxnType.iid('work_order') && root_txn.biz_txn_type && root_txn.biz_txn_type.is_descendant_of?(BizTxnType.iid('work_order'))
      root_txn.work_efforts.each do |work_effort|
        work_effort.destroy
      end
    end
  end

end

module ErpWorkEffort
  module Extensions
    module OrderTxnExtension

      # Extend the clone of OrderTxn to also clone any Tasks associated to this OrderTxn
      #
      # @param [Hash] opts Options for the clone
      # @option opts [Party] :dba_organization The DBA Org to set for the clone, if not passed it will default to the current DBA Org for the cloned OrderTxn
      # @option opts [BizTxnType] :biz_txn_type The BizTxnType to set for the clone, if not passed it will default to the current OrderTxns BizTxnType
      # @option opts [String] :status The status to initialize this OrderTxn with
      # @return [OrderTxn]
      def clone(opts={})
        cloned_order_txn = super(opts)

        root_txn.work_efforts.each do |work_effort|
          cloned_order_txn.root_txn.work_efforts << work_effort.clone
        end

        cloned_order_txn.root_txn.save!

        cloned_order_txn
      end

    end # OrderTxnExtension
  end # Extensions
end # ErpWorkEffort

OrderTxn.prepend ErpWorkEffort::Extensions::OrderTxnExtension
