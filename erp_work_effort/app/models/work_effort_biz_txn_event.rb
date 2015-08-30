#### Table Definition ###########################
# create_table :work_effort_biz_txn_events do |t|
#   t.references :work_effort
#   t.references :biz_txn_event
#
#   t.timestamps
# end
#
# add_index :work_effort_biz_txn_events, :biz_txn_event_id, name: 'bzt_we_biz_txn_event_idx'
# add_index :work_effort_biz_txn_events, :work_effort_id, name: 'bzt_we_work_effort_idx'
#################################################

class WorkEffortBizTxnEvent < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :work_effort
  belongs_to :biz_txn_event

  validates :work_effort_id, presence: true
  validates :biz_txn_event_id, presence: true

end