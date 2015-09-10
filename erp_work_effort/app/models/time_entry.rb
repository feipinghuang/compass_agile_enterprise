# create_table :time_entries do |t|
#   t.datetime :from_datetime
#   t.datetime :thru_datetime
#   t.integer :regular_hours_in_seconds
#   t.integer :overtime_hours_in_seconds
#   t.text :comment
#   t.references :timesheet
#   t.references :work_effort
#
#   t.timestamps
# end
#
# add_index :time_entries, :timesheet_id
# add_index :time_entries, :work_effort_id

class TimeEntry < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :timesheet
  belongs_to :work_effort

  def calculate_regular_hours_in_seconds!
    self.regular_hours_in_seconds = ((thru_datetime - from_datetime)).to_i
    self.save!
  end

  def to_data_hash
    to_hash(only: [:id,
                   :from_datetime,
                   :thru_datetime,
                   :regular_hours_in_seconds,
                   :overtime_hours_in_seconds,
                   :comment,
                   :updated_at,
                   :created_at])
  end

end
