class CreateChargeTypes < ActiveRecord::Migration
  def up
    unless table_exists?(:charge_types)
      create_table :charge_types do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
    end
  end

  def down
    if table_exists?(:charge_types)
      drop_table :charge_types
    end
  end
end
