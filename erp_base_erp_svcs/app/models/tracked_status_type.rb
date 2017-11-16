class TrackedStatusType < ActiveRecord::Base
  attr_accessible :description, :internal_identifier, :external_identifier

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :status_applications

  def to_data_hash
    to_hash(only: [:id,
                   :description,
                   :internal_identifier,
                   :created_at,
                   :updated_at])
  end

end