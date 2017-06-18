class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.string :description
      t.datetime :starttime
      t.datetime :endtime
      t.references :inventory_entry
    end
  end
end
