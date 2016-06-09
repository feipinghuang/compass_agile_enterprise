# create_table :communication_event_pty_roles  do |t|
#   t.references :party
#   t.references :communication_event
#   t.references :role_type
#
#   t.timestamps
# end

# add_index :communication_event_pty_roles, :party_id, name: 'comm_evt_pty_role_pty_idx'
# add_index :communication_event_pty_roles, :communication_event_id, name: 'comm_evt_pty_role_comm_evt_idx'
# add_index :communication_event_pty_roles, :role_type_id, name: 'comm_evt_pty_role_role_idx'

class CommunicationEventPtyRole < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :party
  belongs_to :communication_event
  belongs_to :role_type

end
