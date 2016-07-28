class ChargeType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type

  has_many :charge_lines

  def to_data_hash
  	to_hash(only: [:id, :internal_identifier, :description])
  end
  alias :to_mobile_hash :to_data_hash
  
end
