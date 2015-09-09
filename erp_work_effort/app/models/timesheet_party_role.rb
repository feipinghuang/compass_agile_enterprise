# create_table :timesheet_party_roles do |t|
#   t.references :timesheet
#   t.references :party
#   t.referneces :role_type
#
#   t.timestamps
# end
#
# add_index :timesheet_party_roles, :timesheet_id
# add_index :timesheet_party_roles, :party_id
# add_index :timesheet_party_roles, :role_type_id

class TimesheetPartyRole < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  belongs_to :timesheet
  belongs_to :party
  belongs_to :role_type

end
