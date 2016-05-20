#  create_table :phone_numbers do |t|
#   t.column :phone_number, :string
#   t.column :description, :string
#
#   t.timestamps
#  end

class PhoneNumber < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  validates_format_of :phone_number,
                      with: /^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?)\s*(\d+))?$/,
                      message: "Not a valid North American phone number. Must be 10 digits, extensions are allowed in the format #123 or x123" 
    is_contact_mechanism

  def summary_line
    "#{description} : #{phone_number}"
  end

  def eql_to?(phone)
    self.phone_number.reverse.gsub(/[^0-9]/, "")[0..9] == phone.reverse.gsub(/[^0-9]/, "")[0..9]
  end

  def to_label
    "#{description} : #{to_s}"
  end

  def to_s
    "#{phone_number}"
  end

  def to_data_hash
    to_hash(only: [
              :id,
              :phone_number,
              :description,
              :created_at,
              :updated_at
    ])
  end

end
