Party.class_eval do

  has_many :communication_event_pty_roles, dependent: :destroy

  def communication_events
  	CommunicationEvent.joins(:communication_event_pty_roles)
  	.where(communication_event_pty_roles: {party_id: self.id})
  end

  def from_communication_events
  	communication_events.joins(communication_event_pty_roles: :role_type)
  	.where(role_types: {internal_identifier: 'communication_events_from'})
  end

  def to_communication_events
  	communication_events.joins(communication_event_pty_roles: :role_type)
  	.where(role_types: {internal_identifier: 'communication_events_to'})
  end

end
