class CreateReservationRequests < ActiveRecord::Migration
  def change
    create_table :reservation_requests do |t|
      t.string :description
      t.datetime :starttime
      t.datetime :endtime
      t.references :inventory_entry
      t.references :product_type
      t.text :custom_fields

      t.timestamps
    end
  end
end
