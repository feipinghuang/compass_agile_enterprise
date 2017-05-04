require 'uuid'

class CompassAeInstance < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  has_tracked_status
  has_many :compass_ae_instance_party_roles, :dependent => :destroy do
    def owners
      where('role_type_id = ?', RoleType.compass_ae_instance_owner.id)
    end
  end
  has_many :parties, :through => :compass_ae_instance_party_roles
  validates :guid, :uniqueness => true
  validates :internal_identifier, :presence => {:message => 'internal_identifier cannot be blank'}, :uniqueness => {:case_sensitive => false}

  def installed_engines
    Rails.application.config.erp_base_erp_svcs.compass_ae_engines.map do |compass_ae_engine|
      klass_name = compass_ae_engine.railtie_name.camelize
      {:name => klass_name, :version => ("#{klass_name}::VERSION::STRING".constantize rescue 'N/A')}
    end
  end

  # Find party by role type
  #
  # @param [String || RoleType] role_type Role Type to lookup either an iid or RoleType
  # @return [Party] party with role if found
  def find_party_by_role(role_type)
    if role_type.is_a? String
      role_type = RoleType.iid(role_type)
    end

    parties.where(compass_ae_instance_party_roles: {role_type_id: role_type}).first
  end

  # Add a party with a role type
  #
  # @param [Party] party Party to relate
  # @param [String || RoleType] role_type Role Type to use
  # @return [CompassAeInstancePartyRole] newly created CompassAeInstancePartyRole
  def add_party_with_role(party, role_type)
    if role_type.is_a? String
      role_type = RoleType.iid(role_type)
    end

    unless find_party_by_role(role_type).try(:id) == party.id
      compass_ae_instance_party_roles.create(party: party, role_type: role_type)
    end
  end

  # helpers for guid
  def set_guid(guid)
    self.guid = guid
    self.save
  end

  def get_guid
    self.guid
  end

  def setup_guid
    guid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
    set_guid(guid)
    guid
  end

end
