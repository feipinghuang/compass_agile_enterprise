class AddTenantIdToAuditLog < ActiveRecord::Migration
  def up
    unless column_exists? :audit_logs, :tenant_id
      add_column :audit_logs, :tenant_id, :integer

      add_index :audit_logs, :tenant_id, name: 'audit_logs_tenant_id'
    end
  end

  def down
    if column_exists? :audit_log, :tenant_id
      remove_column :audit_logs, :tenant_id
    end
  end

end
