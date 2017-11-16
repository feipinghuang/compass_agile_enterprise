class MoveTimezoneToParty < ActiveRecord::Migration
  def up
    unless column_exists? :parties, :time_zone
      add_column :parties, :time_zone, :string

      User.all.each do |user|
        if user.time_zone
          user.party.update_column('time_zone', user.time_zone)
        end
      end

      remove_column :users, :time_zone
    end
  end

  def down
    if column_exists? :parties, :time_zone
      add_column :user, :time_zone, :string

      Party.all.each do |party|
        if party.user && user.time_zone
          user.update_column('time_zone', user.time_zone)
        end
      end

      remove_column :parties, :time_zone
    end
  end
end
