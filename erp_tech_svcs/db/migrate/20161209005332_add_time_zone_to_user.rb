class AddTimeZoneToUser < ActiveRecord::Migration
  def up
    unless column_exists? :users, :time_zone
      add_column :users, :time_zone, :string
    end
  end

  def down
    if column_exists? :users, :time_zone
      remove_column :users, :time_zone
    end
  end
end
