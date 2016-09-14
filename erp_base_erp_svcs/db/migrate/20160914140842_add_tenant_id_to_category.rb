class AddTenantIdToCategory < ActiveRecord::Migration
  def up
    unless column_exists? :categories, :tenant_id
      add_column :categories, :tenant_id, :integer

      add_index :categories, :tenant_id, name: 'categories_tenant_idx'
    end
  end

  def down
    if column_exists? :categories, :tenant_id
      remove_column :categories, :tenant_id
    end
  end
end
