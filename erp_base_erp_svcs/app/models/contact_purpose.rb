class ContactPurpose < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  acts_as_erp_type

  has_and_belongs_to_many :contacts

  def to_data_hash
    {
        id: id,
        description: description,
        internal_identifier: internal_identifier
    }
  end
end
