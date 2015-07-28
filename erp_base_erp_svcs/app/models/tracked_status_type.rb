class TrackedStatusType < ActiveRecord::Base
  attr_accessible :description, :internal_identifier

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :status_applications

end