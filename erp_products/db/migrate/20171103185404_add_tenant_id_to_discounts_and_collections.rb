class AddTenantIdToDiscountsAndCollections < ActiveRecord::Migration
  def up
    unless column_exists? :discounts, :tenant_id
      add_column :discounts, :tenant_id, :integer
    end
    unless column_exists? :collections, :tenant_id
      add_column :collections, :tenant_id, :integer
    end
  end

  def down
    if column_exists? :discounts, :tenant_id
      remove_column :discounts, :tenant_id
    end
    if column_exists? :collections, :tenant_id
      remove_column :collections, :tenant_id
    end
  end
end
