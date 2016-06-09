class AddCommunicationEventPartyRoles < ActiveRecord::Migration
  def up

    unless table_exists? :communication_event_pty_roles
      create_table :communication_event_pty_roles  do |t|
        t.references :party
        t.references :communication_event
        t.references :role_type

        t.timestamps
      end

      add_index :communication_event_pty_roles, :party_id, name: 'comm_evt_pty_role_pty_idx'
      add_index :communication_event_pty_roles, :communication_event_id, name: 'comm_evt_pty_role_comm_evt_idx'
      add_index :communication_event_pty_roles, :role_type_id, name: 'comm_evt_pty_role_role_idx'

      communication_events_role_type = RoleType.find_or_create('communication_events', 'Communication Events')
      to_role_type = RoleType.find_or_create('communication_events_to', 'To', communication_events_role_type)
      from_role_type = RoleType.find_or_create('communication_events_from', 'From', communication_events_role_type)

      result = select_all "Select * from communication_events"

      result.each do |row|
        unless row['party_id_from'].blank?
          CommunicationEventPtyRole.create(
            party_id: row['party_id_from'],
            communication_event_id: row['id'],
            role_type: from_role_type
          )
        end

        unless row['party_id_to'].blank?
          CommunicationEventPtyRole.create(
            party_id: row['party_id_to'],
            communication_event_id: row['id'],
            role_type: to_role_type
          )
        end
      end

      remove_column :communication_events, :party_id_from
      remove_column :communication_events, :party_id_to
      remove_column :communication_events, :role_type_id_from
      remove_column :communication_events, :role_type_id_to

    end
  end

  def down
    if table_exists? :communication_event_pty_roles
      add_column :communication_events, :party_id_from, :integer
      add_column :communication_events, :party_id_to, :integer
      add_column :communication_events, :role_type_id_from, :integer
      add_column :communication_events, :role_type_id_to, :integer

      add_index :communication_events, :role_type_id_from
	  add_index :communication_events, :role_type_id_to
	  add_index :communication_events, :party_id_from
	  add_index :communication_events, :party_id_to

	  drop_table :communication_event_pty_roles
    end
  end
end
