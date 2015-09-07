class WorkEffortType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :work_efforts

  def to_data_hash
    to_hash only: [:id, :description, :internal_identifier, :created_at, :updated_at]
  end

end
