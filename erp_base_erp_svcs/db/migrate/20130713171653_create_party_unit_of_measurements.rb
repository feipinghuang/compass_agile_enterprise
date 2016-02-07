class CreatePartyUnitOfMeasurements < ActiveRecord::Migration
  def up
    unless table_exists? :party_unit_of_measurements
      create_table :party_unit_of_measurements do |t|

        t.string :description
        t.string :internal_identifier
        t.string :scope_filter
        t.references :party
        t.references :unit_of_measurement

        t.timestamps
      end
    end

    unless index_exists? :party_unit_of_measurements, :party_id, name: 'party_uom_party_idx'
      add_index :party_unit_of_measurements, :party_id, name: 'party_uom_party_idx'
    end

    unless index_exists? :party_unit_of_measurements, :unit_of_measurement_id, name: 'party_uom_uom_idx'
      add_index :party_unit_of_measurements, :unit_of_measurement_id, name: 'party_uom_uom_idx'
    end
  end

  def down
    drop_table :party_unit_of_measurements
  end
end
