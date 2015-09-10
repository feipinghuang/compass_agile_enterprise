## Easy to confuse this with work_effort_type_associations, which are for associations between types of
## work efforts used for standards or templates. This is the type used when the actual association is created.
## It is still used to store things like dependency and breakdown, but this is the type data and
## work_effort_type_associations is used to store valid combinations of work effort types.

class WorkEffortAssociationType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :work_effort_associations

  def to_data_hash
    to_hash only: [:id, :description, :internal_identifier, :external_identifier, :created_at, :updated_at]
  end

end
