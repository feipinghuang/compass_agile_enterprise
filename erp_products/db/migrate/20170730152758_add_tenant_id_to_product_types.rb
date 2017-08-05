class AddTenantIdToProductTypes < ActiveRecord::Migration
  def up
    unless column_exists? :product_types, :tenant_id
      add_column :product_types, :tenant_id, :integer
      add_index :product_types, :tenant_id, name: 'prod_type_tenant_idx'
    end
  end

  def down
    if column_exists? :product_types, :tenant_id
      remove_column :product_types, :tenant_id
    end
  end
end
