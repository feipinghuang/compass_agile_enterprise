OrderTxn.class_eval do

  before_destroy :destroy_work_items

  def destroy_work_items
    root_txn.work_efforts.each do |work_effort|
      work_effort.destroy
    end
  end

end
