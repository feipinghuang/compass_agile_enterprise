BizTxnEvent.class_eval do

  ## What WorkEfforts have been related to this BizTxnEvent
  has_many :work_effort_biz_txn_events, :dependent => :destroy
  has_many :work_efforts, :through => :work_effort_biz_txn_events

end