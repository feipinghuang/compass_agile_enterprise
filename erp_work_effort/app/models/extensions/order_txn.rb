OrderTxn.class_eval do

  before_destroy :destroy_work_items

  def destroy_work_items
  	# if this is a work order then we should destroy any related tasks
    if BizTxnType.iid('work_order') && root_txn.biz_txn_type.is_descendant_of?(BizTxnType.iid('work_order'))
      root_txn.work_efforts.each do |work_effort|
        work_effort.destroy
      end
    end
  end

end
