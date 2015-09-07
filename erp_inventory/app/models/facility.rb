class Facility < ActiveRecord::Base

  has_many :inventory_entry_locations
  has_many :inventory_entries, :through => :inventory_entry_locations

  belongs_to :postal_address

  def to_data_hash
    to_hash(only: [
                :id,
                :description,
                :created_at,
                :updated_at
            ],
            postal_address: try(:postal_address).try(:to_data_hash))
  end

end
