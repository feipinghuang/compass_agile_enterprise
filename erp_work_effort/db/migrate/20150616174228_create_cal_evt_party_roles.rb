class CreateCalEvtPartyRoles < ActiveRecord::Migration
  def change
    create_table :cal_evt_party_roles do |t|

      t.references  :party
      t.references  :role_type
      t.references  :calendar_event
      t.text        :description

      t.timestamps
    end

    add_index :cal_evt_party_roles, :id, :name => "cepr_id_idx"
    add_index :cal_evt_party_roles, :party_id, :name => "cepr_party_id_idx"
    add_index :cal_evt_party_roles, :calendar_event_id, :name => "cepr__evtid_idx"
    add_index :cal_evt_party_roles, :role_type_id, :name => "cepr_rt_id_idx"

  end
end
