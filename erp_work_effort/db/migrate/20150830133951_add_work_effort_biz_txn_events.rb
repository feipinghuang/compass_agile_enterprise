class AddWorkEffortBizTxnEvents < ActiveRecord::Migration
  def up
    unless table_exists? :work_effort_biz_txn_events
      create_table :work_effort_biz_txn_events do |t|
        t.references :work_effort
        t.references :biz_txn_event

        t.timestamps
      end

      add_index :work_effort_biz_txn_events, :biz_txn_event_id, name: 'bzt_we_biz_txn_event_idx'
      add_index :work_effort_biz_txn_events, :work_effort_id, name: 'bzt_we_work_effort_idx'
    end
  end

  def down
    if table_exists? :work_effort_biz_txn_events
      drop_table :work_effort_biz_txn_events
    end
  end
end
