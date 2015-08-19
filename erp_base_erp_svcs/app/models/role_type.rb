class RoleType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  acts_as_erp_type

  validates :internal_identifier, uniqueness: {message: "Internal Identifiers should be unique"}

  has_many :party_roles
  has_many :parties, :through => :party_roles

end
