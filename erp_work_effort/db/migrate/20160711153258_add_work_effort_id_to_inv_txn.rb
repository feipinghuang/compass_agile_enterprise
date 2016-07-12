class AddWorkEffortIdToInvTxn < ActiveRecord::Migration
  def up
    unless column_exists? :inventory_txns, :work_effort_id
      add_column :inventory_txns, :work_effort_id, :integer
      add_index :inventory_txns, :work_effort_id, name: 'inv_txn_wf_idx'
    end
  end

  def down
    if column_exists? :inventory_txns, :work_effort_id
      remove_column :inventory_txns, :work_effort_id
    end
  end
end
