# create_table :time_entries do |t|
#   t.datetime :from_datetime
#   t.datetime :thru_datetime
#   t.decimal :regular_hours
#   t.decimal :overtime_hours
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
end
