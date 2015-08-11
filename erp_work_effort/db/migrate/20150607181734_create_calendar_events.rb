class CreateCalendarEvents < ActiveRecord::Migration
  def change
    create_table :calendar_events do |t|

      t.string :title
      t.datetime :starttime, :endtime
      t.boolean :all_day, :default => false
      t.boolean :is_public, :default => true
      t.text :description
      t.string :list_view_image_url
      t.string :status

      t.text :custom_fields

      t.timestamps

    end

    add_index :calendar_events, :id, :name => "cal_evt_id_idx"
    add_index :calendar_events, :starttime, :name => "cal_evt_starttime_idx"
    add_index :calendar_events, :endtime, :name => "cal_evt_endtime_idx"

  end
end
