class AddTenantIdToNotification < ActiveRecord::Migration
  def up
    unless column_exists? :notifications, :tenant_id
      add_column :notifications, :tenant_id, :integer
    end
  end

  def down
    if column_exists? :notifications, :tenant_id
      remove_column :notifications, :tenant_id
    end
  end
end
