# create_table :notification_types do |t|
#   t.string :internal_identifier
#   t.string :description
#
#   t.timestamps
# end
#
# add_index :notification_types, :internal_identifier

class NotificationType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type

  has_many :notifications

  validates :internal_identifier, uniqueness: {message: "Internal Identifiers should be unique"}
end