class AddTenantIdToInventoryEntries < ActiveRecord::Migration
  def up
    unless column_exists? :inventory_entries, :tenant_id
      add_column :inventory_entries, :tenant_id, :integer
      add_index :inventory_entries, :tenant_id, name: 'inventory_entries_tenant_id_idx'
    end
  end

  def down
    if column_exists? :inventory_entries, :tenant_id
      remove_column :inventory_entries, :tenant_id
    end
  end
end
