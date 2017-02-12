#  create_table :email_addresses do |t|
#    t.column :email_address, :string
#    t.column :description, :string
#
#    t.timestamps
#  end

class EmailAddress < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_contact_mechanism

  validates_format_of :email_address,
    with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/,
    message: "Must be a valid email address"

  # Get dba_organzation info eventually going to be tenant
  def dba_organization
    self.contact.dba_organization
  end
  alias :tenant :dba_organization

  def summary_line
    "#{description} : #{email_address}"
  end

  def to_label
    "#{description} : #{to_s}"
  end

  def to_s
    "#{email_address}"
  end

  def to_data_hash
    to_hash(only: [
              :id,
              :email_address,
              :description,
              :created_at,
            :updated_at],
            is_primary: self.try(:contact).try(:is_primary))
  end

end
