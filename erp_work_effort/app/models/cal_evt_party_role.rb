class CalEvtPartyRole < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  belongs_to  :calendar_event
  belongs_to  :party
  belongs_to  :role_type

end
