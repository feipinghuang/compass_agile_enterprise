class Requirement < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many :requirement_party_roles, :dependent => :destroy
  has_many :parties, :through => :requirement_party_roles

  #link to support the relationship between requirements and the work_efforts necessary to fulfill them
  has_many  :work_requirement_fulfillments
  has_many  :work_efforts, :through => :work_requirement_fulfillments

  belongs_to :requirement_type
  belongs_to :requirement_record, :polymorphic => true

  has_file_assets

end
