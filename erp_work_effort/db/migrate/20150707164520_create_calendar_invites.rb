class CreateCalendarInvites < ActiveRecord::Migration
  def change
    create_table :calendar_invites do |t|

      t.string      :title
      t.text        :invite_text
      t.references  :calendar_event
      t.integer     :inviter_id
      t.integer     :invitee_id

      t.timestamps

    end

    add_index :calendar_invites, :id, :name => "calendar_invite_id_idx"
    add_index :calendar_invites, :calendar_event_id, :name => "ci_evt_id_idx"
    add_index :calendar_invites, :inviter_id, :name => "ci_inviter_id_idx"
    add_index :calendar_invites, :invitee_id, :name => "ci_invitee_id_idx"

  end
end
