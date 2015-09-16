class UpdateTimeEntries < ActiveRecord::Migration
  def up
    drop_table :time_sheet_entries if table_exists? :time_sheet_entries
    drop_table :time_sheet_entry_party_roles if table_exists? :time_sheet_entry_party_roles

    unless table_exists? :pay_periods
      create_table :pay_periods do |t|
        t.date :from_date
        t.date :thru_date
        t.integer :week_number

        t.timestamps
      end
    end

    unless table_exists? :timesheets
      create_table :timesheets do |t|
        t.text :comment
        t.references :pay_period
        t.string :status

        t.timestamps
      end

      add_index :timesheets, :pay_period_id
    end

    unless table_exists? :time_entries
      create_table :time_entries do |t|
        t.datetime :from_datetime
        t.datetime :thru_datetime
        t.integer :regular_hours_in_seconds
        t.integer :overtime_hours_in_seconds
        t.text :comment
        t.references :timesheet
        t.references :work_effort
        t.boolean :manual_entry

        t.timestamps
      end

      add_index :time_entries, :timesheet_id
      add_index :time_entries, :work_effort_id
    end

    unless table_exists? :timesheet_party_roles
      create_table :timesheet_party_roles do |t|
        t.references :timesheet
        t.references :party
        t.references :role_type

        t.timestamps
      end

      add_index :timesheet_party_roles, :timesheet_id
      add_index :timesheet_party_roles, :party_id
      add_index :timesheet_party_roles, :role_type_id
    end

  end

  def down
    [:pay_periods, :timesheets, :time_entries, :timesheet_party_roles].each do |table|
      if table_exists? table
        drop_table table
      end
    end
  end

end
