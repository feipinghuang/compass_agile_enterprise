class UpdateProductTypeGlAccounts < ActiveRecord::Migration
  def up

    unless column_exists? :product_types, :revenue_gl_account_id
      rename_column :product_types, :biz_txn_acct_root_id, :revenue_gl_account_id

      add_index :product_types, :revenue_gl_account_id, name: 'product_types_rev_gl_acct_idx'
    end

    unless column_exists? :product_types, :expense_gl_account_id
      add_column :product_types, :expense_gl_account_id, :integer

      add_index :product_types, :expense_gl_account_id, name: 'product_types_exp_gl_acct_idx'
    end
  end

  def down

    if column_exists? :product_types, :revenue_gl_account_id
      rename_column :product_types, :revenue_gl_account_id, :biz_txn_acct_root_id
    end

    if column_exists? :product_types, :expense_gl_account_id
      remove_column :product_types, :expense_gl_account_id
    end

  end
end
