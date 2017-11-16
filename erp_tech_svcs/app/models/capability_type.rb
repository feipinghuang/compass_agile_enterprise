class CapabilityType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  attr_accessible :description, :internal_identifier
  has_many :capabilities
end
