class AddStarttimeAndEndtimeToInventoryEntries < ActiveRecord::Migration
  def change
    add_column :inventory_entries, :starttime, :datetime
    add_column :inventory_entries, :endtime, :datetime
  end
end
