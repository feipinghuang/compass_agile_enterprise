class CalendarInvite < ActiveRecord::Base

  belongs_to  :calendar_event
  belongs_to  :inviter, :class_name => "Party", :foreign_key => "inviter_id"
  belongs_to  :invitee, :class_name => "Party", :foreign_key => "invitee_id"

  has_tracked_status
  # attr_accessible :title, :body

end
