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

  class << self
    def open
      where('thru_datetime is null')
    end

    # scope by work_effort
    #
    # @param work_effort [Integer | WorkEffort | Array] either a id of WorkEffort record, a WorkEffort record, an array of WorkEffort records
    # or an array of WorkEffort ids
    #
    # @return [ActiveRecord::Relation]
    def scope_by_work_effort(work_effort)
      where(work_effort_id: work_effort)
    end

    # entries scoped by party
    #
    # @param party [Party] party to get time_entries by
    def scope_by_party(party)
      joins(:timesheet => :timesheet_party_roles).where('timesheet_party_roles.party_id' => party)
    end

    # total seconds by work_effort
    #
    # @param opts [Hash] opts to calculate the total with
    # @option opts [WorkEffort] :work_effort WorkEffort to get total hours for
    # @option opts [Party] :party Party to get total hours for
    # @option opts [Date] :start start date range
    # @option opts [Date] :end end date range
    #
    # @return [Integer] total seconds
    def total_seconds(opts)
      seconds = 0

      time_entry_arel_tbl = self.arel_table

      if opts[:work_effort]
        statement = self.scope_by_work_effort(opts[:work_effort])
      end

      if opts[:party]
        statement = self.scope_by_party(opts[:party])
      end

      if opts[:start]
        statement = statement.where(time_entry_arel_tbl[:from_datetime].gteq(opts[:start]))
      end

      if opts[:end]
        statement = statement.where(time_entry_arel_tbl[:from_datetime].lteq(opts[:end]))
      end

      statement.each do |time_entry|
        seconds += ((time_entry.regular_hours_in_seconds || 0) + (time_entry.overtime_hours_in_seconds || 0))
      end

      seconds
    end

    # total seconds by work_effort formatted as HH:MM:SS
    #
    # @param opts [Hash] opts to calculate the total with
    # @option opts [WorkEffort] :work_effort WorkEffort to get total hours for
    # @option opts [Party] :party Party to get total hours for
    # @option opts [Date] :start start date range
    # @option opts [Date] :end end date range
    #
    # @return [String] HH:MM:SS
    def total_formatted(opts)
      Time.at(total_seconds(opts)).utc.strftime("%H:%M:%S")
    end
  end

  def calculate_regular_hours_in_seconds!
    self.regular_hours_in_seconds = ((thru_datetime - from_datetime)).to_i
    self.save!
  end

  #
  # relationship helpers
  #

  # create relationship between a TimeEntry and WorkEffort
  #
  # @param work_effort [WorkEffort] work_effort to relate this time_entry to
  #
  # @return [TimeEntry] self
  def create_work_effort_relationship(work_effort)
    self.work_effort_id = work_effort.id

    self
  end

  # destroy relationship between a TimeEntry and WorkEffort
  #
  # @return [TimeEntry] self
  def destroy_work_effort_relationship
    self.work_effort_id = nil

    self
  end

  #
  # end relationship helpers
  #

  # regular hours formatted as HH:MM:SS
  #
  # @return [String] HH:MM:SS
  def regular_hours_formatted
    Time.at((self.regular_hours_in_seconds || 0)).utc.strftime("%H:%M:%S")
  end

  # overtime hours formatted as HH:MM:SS
  #
  # @return [String] HH:MM:SS
  def overtime_hours_formatted
    Time.at((self.overtime_hours_in_seconds || 0)).utc.strftime("%H:%M:%S")
  end

  def to_data_hash
    to_hash(only: [:id,
                   :regular_hours_in_seconds,
                   :overtime_hours_in_seconds,
                   :comment],
            from_datetime: (from_datetime.nil? ? nil : from_datetime.utc.iso8601),
            thru_datetime: (thru_datetime.nil? ? nil : thru_datetime.utc.iso8601),
            updated_at: (updated_at.nil? ? nil : updated_at.utc.iso8601),
            created_at: (created_at.nil? ? nil : created_at.utc.iso8601)
    )
  end

end
