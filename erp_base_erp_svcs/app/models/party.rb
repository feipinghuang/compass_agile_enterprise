class Party < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_notes
  has_contacts
  tracks_created_by_updated_by

  has_many :created_notes, :class_name => 'Note', :foreign_key => 'created_by_id'
  belongs_to :business_party, :polymorphic => true

  has_many :entity_party_roles, dependent: :destroy

  has_many :party_roles, :dependent => :destroy #role_types
  has_many :role_types, :through => :party_roles

  after_destroy :destroy_business_party, :destroy_party_relationships

  attr_reader :relationships
  attr_writer :create_relationship

  class << self
    # scope by dba organization
    #
    # @param dba_organization [Party, Array] dba organization to scope by or Array of dba organizations to
    # scope by
    #
    # @return [ActiveRecord::Relation]
    def scope_by_dba_organization(dba_organization)
      joins("inner join party_relationships on party_relationships.role_type_id_to ='#{RoleType.iid('dba_org').id}'
             and party_relationships.party_id_from = parties.id")
      .where({party_relationships: {party_id_to: dba_organization}})
    end

    # Scopes parties by passed role types
    #
    # @param role_types [Array, RoleType] Array of RoleTypes to scope by
    def with_role_types(role_types)
      joins('inner join party_roles on party_roles.party_id = parties.id').where('party_roles.role_type_id' => role_types)
    end

  end

  # helper method to get dba_organization related to this party
  #
  # @return [Party] DBA Organization
  def dba_organization
    find_related_parties_with_role('dba_org').first
  end

  # Get any child DBA Organizations related this party
  #
  # @param dba_orgs [Array] Array of current DBA Organizations to add to
  # @return [Array] Child DBA Organizations
  def child_dba_organizations(dba_orgs=[])
    dba_org = RoleType.iid('dba_org')

    PartyRelationship.joins('inner join parties on parties.id = party_relationships.party_id_from')
    .joins('inner join party_roles on party_roles.party_id = party_relationships.party_id_from')
    .where('party_id_to' => self.id)
    .where('party_relationships.role_type_id_to' => dba_org)
    .where('party_roles.role_type_id' => dba_org).each do |party_reln|

      dba_orgs.push(party_reln.from_party)
      if !dba_orgs.collect(&:id).include? party_reln.from_party.id
        party_reln.from_party.child_dba_organizations(dba_orgs)
      end

    end

    dba_orgs.uniq
  end

  # Get all parties that have a relationship to this party. If deep is passed then of those parties do the same
  # all the way down the relationship chain
  #
  # @param parties [Array] Array of currently found related parties
  # @return [Array] Array of related parties
  def parties_in_relationships(parties=[], deep=false)
    PartyRelationship.where('party_id_to' => self.id).each do |party_reln|

      parties.push(party_reln.from_party) unless parties.include?(party_reln.from_party)
      if deep and !parties.collect(&:id).include? party_reln.from_party.id
        party_reln.from_party.parties_in_relationships(parties, deep)
      else
        parties
      end

    end

    parties.uniq
  end

  # Get any parent DBA Organizations related this party
  #
  # @param dba_orgs [Array] Array of current DBA Organizations to add to
  # @return [Array] Parent DBA Organizations
  def parent_dba_organizations(dba_orgs=[])
    PartyRelationship.
      where('party_id_from = ?', id).
    where('role_type_id_to' => RoleType.iid('dba_org')).each do |party_reln|

      dba_orgs.push(party_reln.to_party)
      party_reln.to_party.parent_dba_organizations(dba_orgs)
    end

    dba_orgs.uniq
  end

  # Gathers all party relationships that contain this particular party id
  # in either the from or to side of the relationship.
  def relationships
    @relationships ||= PartyRelationship.where('party_id_from = ? or party_id_to = ?', id, id)
  end

  def to_relationships
    @relationships ||= PartyRelationship.where('party_id_to = ?', id)
  end

  def from_relationships
    @relationships ||= PartyRelationship.where('party_id_from = ?', id)
  end

  def find_related_parties_with_role(role_type_iid)
    Party.joins(:party_roles).joins("inner join party_relationships on (party_id_from = #{id} and parties.id = party_relationships.party_id_to)")
    .where(PartyRole.arel_table[:role_type_id].eq(RoleType.iid(role_type_iid).id))
    .where(Party.arel_table[:id].not_eq(id))
  end

  def find_relationships_by_type(relationship_type_iid)
    PartyRelationship.includes(:relationship_type).
      where('party_id_from = ? or party_id_to = ?', id, id).
      where('relationship_types.internal_identifier' => relationship_type_iid.to_s)
  end

  # Creates a new PartyRelationship for this particular
  # party instance.
  def create_relationship(description, to_party_id, reln_type)
    PartyRelationship.create(:description => description,
                             :relationship_type => reln_type,
                             :party_id_from => id,
                             :from_role => reln_type.valid_from_role,
                             :party_id_to => to_party_id,
                             :to_role => reln_type.valid_to_role)
  end

  # Callbacks
  def destroy_business_party
    if self.business_party
      self.business_party.destroy
    end
  end

  def destroy_party_relationships
    PartyRelationship.destroy_all("party_id_from = #{id} or party_id_to = #{id}")
  end

  def add_role_type(role)
    role = role.is_a?(RoleType) ? role : RoleType.iid(role)

    PartyRole.create(party: self, role_type: role)
  end

  def has_role_type?(*passed_roles)
    result = false
    passed_roles.flatten!
    passed_roles.each do |role|
      role_iid = role.is_a?(RoleType) ? role.internal_identifier : role.to_s

      PartyRole.where(party_id: self.id).each do |party_role|
        result = true if (party_role.role_type.internal_identifier == role_iid)
        break if result
      end

    end
    result
  end

  # Alias for to_s
  def to_label
    to_s
  end

  def to_s
    "#{description}"
  end

  # convert party record to hash of data
  #
  def to_data_hash
    data = to_hash(only: [
                     :id,
                     :description,
                     :created_at,
                     :updated_at
                   ],
                   business_party_type: business_party.class.name
                   )

    # get business party data
    if business_party
      if business_party.is_a?(Individual)
        data.merge!({
                      first_name: business_party.current_first_name,
                      last_name: business_party.current_last_name,
                      middle_name: business_party.current_middle_name,
                      gender: business_party.gender
        })
      else
        data.merge!({
                      tax_id_number: business_party.tax_id_number
        })
      end
    end

    data
  end

end
