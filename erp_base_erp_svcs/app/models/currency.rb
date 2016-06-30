class Currency < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many :money

  def symbol
    major_unit_symbol
  end

  def self.usd
    # Pull the usd currency from GeoCountry
    find_by_internal_identifier("USD")
  end

  def self.blank
    new
  end

  def to_data_hash
    to_hash(only: [:id, :internal_identifier])
  end
end
