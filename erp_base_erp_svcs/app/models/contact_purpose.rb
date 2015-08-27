class ContactPurpose < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  acts_as_erp_type

  has_and_belongs_to_many :contacts

  def to_data_hash
    to_hash(
        only: [
            :id,
            :description,
            :internal_identifier,
            :created_at,
            :updated_at
        ],
        leaf: leaf?
    )
  end
end
