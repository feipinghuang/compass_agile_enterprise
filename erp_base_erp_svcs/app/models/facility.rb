class Facility < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_tenantable
  acts_as_fixed_asset

  #Allow for polymorphic associated subclsses of Facility
  belongs_to :facility_record, :polymorphic => true
  belongs_to :facility_type

  belongs_to :postal_address

end
