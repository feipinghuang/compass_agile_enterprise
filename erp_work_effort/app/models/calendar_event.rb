class CalendarEvent < ActiveRecord::Base

  # attr_accessible :title, :body
  attr_accessor :invitee_status

  has_many :cal_evt_party_roles, dependent: :destroy
  has_many :parties, :through => :cal_evt_party_roles
  has_many :calendar_invites, dependent: :destroy
  has_file_assets

  # serialize ExtJs attributes
  is_json :custom_fields

  def invitee_status_for_party( invitee_party_id )
    invite = CalendarInvite.where( "invitee_id = ? and calendar_event_id = ?", invitee_party_id, self.id ).first
    invite ? invite.current_status : nil
  end

  def get_invitees
    self.calendar_invites.map { |i| i.invitee }.compact
  end

  def get_accepted_invitees
    self.calendar_invites.select{ |i| i.current_status == 'accepted'}.map { |i| i.invitee }.compact
  end

  def primary_event_host
    self.parties.where("role_type_id = ?", RoleType.iid('cal_evt_host')).first
  end

  def find_parties_by_role(role)
    self.parties.where("role_type_id = ?", role.id).all
  end

  #This is a convenience method whose primary use is when a CalendarEvent starts out using specific invitations
  #and later gets changed to being a public or network-type invite. You can clean up un-accepted invitations
  #and invitees can still accept via the public or network invite.
  def remove_unaccepted_invitations

  end

  def to_json
    super methods: [:invitee_status]
  end

end
