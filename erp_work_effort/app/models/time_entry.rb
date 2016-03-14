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

  tracks_created_by_updated_by

  belongs_to :timesheet
  belongs_to :work_effort

  class << self
    def open
      where(TimeEntry.arel_table[:from_datetime].not_eq(nil))
          .where(thru_datetime: nil)
          .where(TimeEntry.arel_table[:manual_entry].eq(nil).or(TimeEntry.arel_table[:manual_entry].eq(false)))
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

      statement = self

      time_entry_arel_tbl = self.arel_table

      if opts[:work_effort]
        statement = statement.scope_by_work_effort(opts[:work_effort])
      end

      if opts[:party]
        statement = statement.scope_by_party(opts[:party])
      end

      if opts[:start]
        statement = statement.where(time_entry_arel_tbl[:from_datetime].gteq(opts[:start].utc).
                                        or(time_entry_arel_tbl[:manual_entry_start_date].gteq(opts[:start].utc)))
      end

      if opts[:end]
        statement = statement.where(time_entry_arel_tbl[:from_datetime].lteq(opts[:end].utc).
                                        or(time_entry_arel_tbl[:manual_entry_start_date].lteq(opts[:end].utc)))
      end

      statement.each do |time_entry|
        seconds += ((time_entry.regular_hours_in_seconds || 0) + (time_entry.overtime_hours_in_seconds || 0))
      end

      seconds
    end

    # total hours as decimal round to the nearest 15th
    #
    # @param opts [Hash] opts to calculate the total with
    # @option opts [WorkEffort] :work_effort WorkEffort to get total hours for
    # @option opts [Party] :party Party to get total hours for
    # @option opts [Date] :start start date range
    # @option opts [Date] :end end date range
    #
    # @return [BigDecimal] hours
    def total_hours(opts)
      _total_seconds = total_seconds(opts)

      if _total_seconds.nil? or _total_seconds == 0
        0
      else
        # get hours by dividing seconds by 3600 then get fractional minutes
        ((_total_seconds / 3600).floor + (((_total_seconds % 3600) / 60)) / 100.0)
      end
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
      _total_seconds = total_seconds(opts)

      if _total_seconds.nil? or _total_seconds == 0
        '00:00:00'
      else
        seconds =_total_seconds % 60
        minutes = (_total_seconds / 60) % 60
        hours = _total_seconds / (60 * 60)

        format("%02d:%02d:%02d", hours, minutes, seconds)
      end
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
    if self.regular_hours_in_seconds.nil? or self.regular_hours_in_seconds == 0
      '00:00:00'
    else
      seconds = self.regular_hours_in_seconds % 60
      minutes = (self.regular_hours_in_seconds / 60) % 60
      hours = self.regular_hours_in_seconds / (60 * 60)

      format("%02d:%02d:%02d", hours, minutes, seconds)
    end
  end

  # overtime hours formatted as HH:MM:SS
  #
  # @return [String] HH:MM:SS
  def overtime_hours_formatted
    if self.overtime_hours_in_seconds.nil? or self.overtime_hours_in_seconds == 0
      '00:00:00'
    else
      seconds = self.overtime_hours_in_seconds % 60
      minutes = (self.overtime_hours_in_seconds / 60) % 60
      hours = self.overtime_hours_in_seconds / (60 * 60)

      format("%02d:%02d:%02d", hours, minutes, seconds)
    end
  end

  # get fractional hours for this TimeEntry
  #
  # @return [BigDecimal] hours
  def hours
    _total_seconds = (self.regular_hours_in_seconds || 0) + (self.overtime_hours_in_seconds || 0)

    if _total_seconds.nil? or _total_seconds == 0
      0
    else
      # get hours by dividing seconds by 3600 then get fractional minutes
      ((_total_seconds / 3600).floor + (((_total_seconds % 3600) / 60)) / 100.0)
    end
  end

  # finds party with passed role to this TimeEntry
  #
  # @param role_type [RoleType] role type to use in the association
  # @return [Party] party
  def find_party_by_role(role_type)
    self.timesheet.find_party_by_role(role_type)
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

  # Sets the current status of the WorkEffort to In Progress
  #
  # @param status [String] Internal Identifier of TrackedStatusType to set
  def update_task_status(status)
    # make sure this TimeEntry is related to a WorkEffort
    if self.work_effort
      work_effort.current_status = status
    end
  end

  # Sets the current status of the WorkEffortAssignment to In Progress
  #
  # @param status [String] Internal Identifier of TrackedStatusType to set
  def update_task_assignment_status(status)
    # make sure this TimeEntry is related to a WorkEffort
    if self.work_effort
      work_resource_role_types = RoleType.find_child_role_types(['work_resource'])

      # find the party with work_resource related to this TimeEntry
      work_resource_party = self.find_party_by_role(work_resource_role_types)

      assignment = work_effort.work_effort_party_assignments.where(party_id: work_resource_party)
                       .where(role_type_id: work_resource_role_types).first

      if assignment
        assignment.current_status = status
      end
    end
  end

end
