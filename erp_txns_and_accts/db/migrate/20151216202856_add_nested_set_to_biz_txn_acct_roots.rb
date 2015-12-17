class AddNestedSetToBizTxnAcctRoots < ActiveRecord::Migration
  def up
    unless column_exists? :biz_txn_acct_roots, :parent_id
      add_column :biz_txn_acct_roots, :parent_id, :integer
      add_column :biz_txn_acct_roots, :lft, :integer
      add_column :biz_txn_acct_roots, :rgt, :integer

      add_index :biz_txn_acct_roots, :parent_id
      add_index :biz_txn_acct_roots, :lft
      add_index :biz_txn_acct_roots, :rgt

      BizTxnAcctRoot.rebuild!
    end

    unless column_exists? :biz_txn_acct_roots, :internal_identifier
      add_column :biz_txn_acct_roots, :internal_identifier, :string
    end
  end

  def down
    if column_exists? :biz_txn_acct_roots, :parent_id
      remove_column :biz_txn_acct_roots, :parent_id
      remove_column :biz_txn_acct_roots, :lft
      remove_column :biz_txn_acct_roots, :rgt
    end

    if column_exists? :biz_txn_acct_roots, :internal_identifier
      remove_column :biz_txn_acct_roots, :internal_identifier
    end
  end
end
