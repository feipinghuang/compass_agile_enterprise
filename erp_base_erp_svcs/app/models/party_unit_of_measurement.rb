# create_table :party_unit_of_measurements do |t|
#
#   t.string :description
#   t.string :internal_identifier
#   t.string :scope_filter
#   t.references :party
#   t.references :unit_of_measurement
#
#   t.timestamps
# end
#
# add_index :party_unit_of_measurements, :party_id, name: 'party_uom_party_idx'
#
# add_index :party_unit_of_measurements, :unit_of_measurement, name: 'party_uom_uom_idx'

class PartyUnitOfMeasurement < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :party
  belongs_to :unit_of_measurement

end
