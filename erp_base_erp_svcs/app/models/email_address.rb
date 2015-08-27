#  create_table :email_addresses do |t|
#    t.column :email_address, :string
#    t.column :description, :string
#
#    t.timestamps
#  end

class EmailAddress < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_contact

  validates_format_of :email_address, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "Must be a valid email address"

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
                :email_address,
                :description,
                :created_at,
                :updated_at
            ])
  end

end
