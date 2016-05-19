class UpdateCommunicationEvents < ActiveRecord::Migration
  def up
    unless column_exists? :communication_events, :start_at
      rename_column :communication_events, :date_time_started, :start_at
    end

    unless column_exists? :communication_events, :end_at
      rename_column :communication_events, :date_time_ended, :end_at
    end

    if column_exists? :communication_events, :status_type_id
      remove_column :communication_events, :status_type_id
    end
  end

  def down
    if column_exists? :communication_events, :start_at
      rename_column :communication_events, :start_at, :date_time_started
    end

    if column_exists? :communication_events, :end_at
      rename_column :communication_events, :end_at, :date_time_ended
    end

    unless column_exists? :communication_events, :status_type_id
      add_column :communication_events, :status_type_id, :integer
    end
  end
end
