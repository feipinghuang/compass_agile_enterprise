class AddBizTxnAcctRootToProducts < ActiveRecord::Migration
  def up
    unless column_exists? :product_types, :biz_txn_acct_root_id
      add_column :product_types, :biz_txn_acct_root_id, :integer

      add_index :product_types, :biz_txn_acct_root_id
    end
  end

  def down
    if column_exists? :product_types, :biz_txn_acct_root_id
      remove_column :product_types, :biz_txn_acct_root_id
    end
  end
end
