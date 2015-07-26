class TaskType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  acts_as_erp_type
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :tasks

end
