class CapabilityAccessor < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :capability_accessor_record, :polymorphic => true
  belongs_to :capability
end
