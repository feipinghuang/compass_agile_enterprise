# create_table :inventory_entry_locations do |t|
#   t.references :inventory_entry
#   t.references :facility
#   t.datetime :valid_from
#   t.datetime :valid_thru
#
#   t.timestamps
# end
#
# add_index :inventory_entry_locations, :inventory_entry_id, :name => "inv_entry_loc_inv_entry_idx"
# add_index :inventory_entry_locations, :facility_id, :name => "inv_entry_loc_facility_idx"

class InventoryEntryLocation < ActiveRecord::Base
  attr_protected :created_at, :upated_at

  default_scope order('created_at ASC')

  belongs_to  :inventory_entry
  belongs_to  :facility
  belongs_to  :postal_address

  def address
    self.postal_address
  end

  def to_data_hash
    data = to_hash(only: [
                     :id,
                     :valid_from,
                     :valid_thru,
                     :created_at,
                     :updated_at
                   ],
                   postal_address: try(:postal_address).try(:to_data_hash))

    if facility
      data[:facility] = facility.to_data_hash
    end

    if inventory_entry
      data[:inventory_entry] = inventory_entry.to_data_hash
    end

    data
  end
end
