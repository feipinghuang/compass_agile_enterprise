class AddBizTxnAcctRootIdToInvoiceItem < ActiveRecord::Migration
  def up
    unless column_exists? :invoice_items, :biz_txn_acct_root_id
      add_column :invoice_items, :biz_txn_acct_root_id, :integer

      add_index :invoice_items, :biz_txn_acct_root_id
    end
  end

  def down
    if column_exists? :invoice_items, :biz_txn_acct_root_id
      remove_column :invoice_items, :biz_txn_acct_root_id
    end
  end
end
