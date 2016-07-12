class AddTenantIdToFacilities < ActiveRecord::Migration
  def up
    unless column_exists? :facilities, :tenant_id
      add_column :facilities, :tenant_id, :integer
      add_index :facilities, :tenant_id, name: 'facilities_tenant_id_idx'
    end
  end

  def down
    if column_exists? :facilities, :tenant_id
      remove_column :facilities, :tenant_id
    end
  end
end
