class AddTenantIdToPricingPlans < ActiveRecord::Migration
  def up
    unless column_exists? :pricing_plans, :tenant_id
      add_column :pricing_plans, :tenant_id, :integer
      add_index :pricing_plans, :tenant_id, name: 'pricing_plans_tenant_id_idx'
    end
  end

  def down
    if column_exists? :pricing_plans, :tenant_id
      remove_column :pricing_plans, :tenant_id
    end
  end
end
