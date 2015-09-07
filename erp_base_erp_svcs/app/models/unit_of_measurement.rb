class UnitOfMeasurement < ActiveRecord::Base

  has_one :carrier_unit_of_measurement

  attr_accessible :description

  def to_data_hash
    to_hash(only: [:id,
                   :description,
                   :created_at,
                   :updated_at])
  end

end