class AddTokenTenantIdToBanks < ActiveRecord::Migration
  def up
    unless column_exists? :bank_accounts, :bank_token
      add_column :bank_accounts, :bank_token, :string
    end

    unless column_exists? :bank_accounts, :account_holder_type
      add_column :bank_accounts, :account_holder_type, :string
    end

    unless column_exists? :bank_accounts, :tenant_id
      add_column :bank_accounts, :tenant_id, :integer
      add_index :bank_accounts, :tenant_id, name: 'bank_accounts_tenant_id_idx'
    end

    unless column_exists? :bank_accounts, :custom_fields
      add_column :bank_accounts, :custom_fields, :text
    end
  end

  def down
    if column_exists? :bank_accounts, :bank_token
      remove_column :bank_accounts, :bank_token
    end

    if column_exists? :bank_accounts, :tenant_id
      remove_column :bank_accounts, :tenant_id
    end

    if column_exists? :bank_accounts, :account_holder_type
      remove_column :bank_accounts, :account_holder_type
    end

    if column_exists? :bank_accounts, :custom_fields
      remove_column :bank_accounts, :custom_fields
    end
  end
end
