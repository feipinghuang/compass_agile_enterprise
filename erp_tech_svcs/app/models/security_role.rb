class SecurityRole < ActiveRecord::Base
  attr_accessible :description, :internal_identifier

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_capability_accessors
  has_and_belongs_to_many :parties

  validates :description, :presence => {:message => 'Description cannot be blank'}
  validates :internal_identifier, :presence => {:message => 'Internal identifier cannot be blank'}
  validates_uniqueness_of :internal_identifier, :case_sensitive => false
  validates_length_of     :internal_identifier, :within => 3..100

  def to_xml(options = {})
    default_only = []
    options[:only] = (options[:only] || []) + default_only
    super(options)
  end

  def to_s
    internal_identifier
  end

  # creating method because we only want a getter, not a setter for iid
  def iid
    self.internal_identifier
  end

  def join_parties_security_roles
    "parties_security_roles ON parties_security_roles.party_id=parties.id AND parties_security_roles.security_role_id=#{self.id}"
  end

  # users with this role
  def users
    User.joins(:party).joins("JOIN #{join_parties_security_roles}")
  end

  # users without this role
  def users_not
    User.joins(:party).joins("LEFT JOIN #{join_parties_security_roles}").where("parties_security_roles.security_role_id IS NULL")
  end

  # groups with this role
  def groups
    Group.joins(:party).joins("JOIN #{join_parties_security_roles}")
  end

  # groups without this role
  def groups_not
    Group.joins(:party).joins("LEFT JOIN #{join_parties_security_roles}").where("parties_security_roles.security_role_id IS NULL")
  end

  def to_data_hash
    hash = to_hash(:only => [:id, :description, :internal_identifier, :created_at, :updated_at])

    if parent
      hash[:parent] = parent.to_data_hash
    end

    hash
  end

end
