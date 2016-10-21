class AddTenantIdToCommEvt < ActiveRecord::Migration
  def up
    unless column_exists? :communication_events, :tenant_id
      add_column :communication_events, :tenant_id, :integer
      add_index :communication_events, :tenant_id, name: 'communication_event_tenant_idx'
    end
  end

  def down
    if column_exists? :communication_events, :tenant_id
      remove_column :communication_events, :tenant_id, :integer
    end
  end
end
