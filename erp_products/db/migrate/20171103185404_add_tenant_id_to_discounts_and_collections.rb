class AddTenantIdToDiscountsAndCollections < ActiveRecord::Migration
  def change
    unless column_exists? :discounts, :tenant_id
      add_column :discounts, :tenant_id, :integer
    end
    unless column_exists? :collections, :tenant_id
      add_column :collections, :tenant_id, :integer
    end
  end
end
