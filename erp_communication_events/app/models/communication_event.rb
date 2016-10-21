# create_table :communication_events do |t|
#   t.integer  :from_contact_mechanism_id
#   t.string   :from_contact_mechanism_type
#
#   t.integer  :to_contact_mechanism_id
#   t.string   :to_contact_mechanism_type
#
#   t.string   :short_description
#   t.integer  :case_id
#   t.datetime :start_at
#   t.datetime :end_at
#   t.string   :notes
#   t.string   :external_identifier
#   t.string   :external_id_source
#
#   t.integer :tenant_id
#
#   t.timestamps
# end
#
# add_index :communication_events, :status_type_id
# add_index :communication_events, :case_id
# add_index :communication_events, :tenant_id, name: 'communication_event_tenant_idx'
# add_index :communication_events, [:to_contact_mechanism_id, :to_contact_mechanism_type], :name => 'to_contact_mech_idx'
# add_index :communication_events, [:from_contact_mechanism_id, :from_contact_mechanism_type], :name => 'from_contact_mech_idx'

class CommunicationEvent < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_tenantable

  belongs_to :from_contact_mechanism, :polymorphic => true
  belongs_to :to_contact_mechanism, :polymorphic => true

  has_and_belongs_to_many :comm_evt_purpose_types, :join_table => 'comm_evt_purposes'

  has_many :communication_event_pty_roles, dependent: :destroy

  has_tracked_status
  tracks_created_by_updated_by

  class << self
    # scope by party
    #
    # @param party [Integer | Party | Array] either a id of Party record, a Party record, an array of Party records
    # or an array of Party ids
    # @param options [Hash] options to apply to this scope
    # @option options [Array] :role_types role types to include in the scope
    #
    # @return [ActiveRecord::Relation]
    def scope_by_party(party, options={})
      if options[:role_types]
        joins(communication_event_pty_roles: :role_type)
        .where(communication_event_pty_roles: {party_id: party, role_type_id: options[:role_types]})

      else
        joins(:communication_event_pty_roles).where(communication_event_pty_roles: {party_id: party})
      end
    end
  end

  def parties
    Party.joins(:communication_event_pty_roles)
    .where(communication_event_pty_roles: {communication_event_id: self.id})
  end

  def to_parties
    parties.joins(communication_event_pty_roles: :role_type)
    .where(role_types: {internal_identifier: 'communication_events_to'})
  end

  def from_parties
    parties.joins(communication_event_pty_roles: :role_type)
    .where(role_types: {internal_identifier: 'communication_events_from'})
  end

  # Helper method if this communication event only has one to party
  #
  def to_party
    to_parties.first
  end

  # Helper method if this communication event only has one to party
  #
  def to_party=(party)
    remove_to_parties

    add_party(party, 'communication_events_to')
  end

  # Helper method if this communication event only has one from party
  #
  def from_party
    from_parties.first
  end

  # Helper method if this communication event only has one from party
  #
  def from_party=(party)
    remove_from_parties

    add_party(party, 'communication_events_from')
  end

  def add_from_party(party)
    add_party(party, 'communication_events_from')
  end

  def remove_from_parties
    remove_parties('communication_events_from')
  end

  def add_to_party(party)
    add_party(party, 'communication_events_to')
  end

  def remove_to_parties
    remove_parties('communication_events_to')
  end

  # Add party with role type
  #
  def add_party(party, role_type)
    if role_type.is_a? String
      role_type = RoleType.iid(role_type)
    end

    communication_event_pty_roles.create(party: party, role_type: role_type)
  end

  def remove_parties(role_type)
    if role_type.is_a? String
      role_type = RoleType.iid(role_type)
    end

    communication_event_pty_roles.joins(:role_type)
    .where(role_types: {id: role_type}).each do |communication_event_pty_role|
      communication_event_pty_role.destroy
    end
  end

  def to_s
    "#{short_description}"
  end
  alias :to_label :to_s

end
