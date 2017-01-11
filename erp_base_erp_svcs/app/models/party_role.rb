class PartyRole < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :party, :class_name => "Party", :foreign_key => "party_id"
  belongs_to :role_type, :class_name => "RoleType", :foreign_key => "role_type_id"

  # Get dba_organzation info eventually going to be tenant
  def dba_organization
    self.party.dba_organization
  end
  alias :tenant :dba_organization
  def tenant_id
    tenant.id
  end

  def to_label
    self.role_type.description
  end
end