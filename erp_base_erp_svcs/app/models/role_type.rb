class RoleType < ActiveRecord::Base
  attr_accessible :description, :internal_identifier

  acts_as_nested_set
  acts_as_erp_type

  validates :internal_identifier, uniqueness: {message: "should be unique"}

  has_many :party_roles
  has_many :parties, :through => :party_roles

  def to_s
    internal_identifier
  end

  # finds all child role types for given role types.
  #
  # @param role_types [Array] role type internal identifiers or records
  # @returns [Array] role types based and any of their children in a flat array
  def self.find_child_role_types(role_types)
    all_role_types = []

    role_types.each do |role_type|

      if role_type.is_a?(String)
        role_type = RoleType.iid(role_type)
      end

      all_role_types.concat role_type.self_and_descendants
    end

    all_role_types.flatten
  end

end
