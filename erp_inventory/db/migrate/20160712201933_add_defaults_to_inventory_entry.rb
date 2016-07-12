class AddDefaultsToInventoryEntry < ActiveRecord::Migration
  def change
    change_column :inventory_entries, :number_available, :decimal, default: 0
    change_column :inventory_entries, :number_sold, :decimal, default: 0
    change_column :inventory_entries, :number_in_stock, :decimal, default: 0
  end
end
