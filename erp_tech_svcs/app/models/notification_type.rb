class NotificationType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type

  has_many :notifications

  validates :internal_identifier, uniqueness: {message: "Internal Identifiers should be unique"}

  RoleType
end