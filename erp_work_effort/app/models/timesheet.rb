# create_table :timesheets do |t|
#   t.text :comment
#   t.references :pay_period
#   t.string :status
#
#   t.timestamps
# end
#
# add_index :timesheets, :party_id
# add_index :timesheets, :pay_period_id

class Timesheet < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  include AASM

  has_file_assets

  has_many :timesheet_party_roles
  has_many :time_entries
  belongs_to :pay_period

  scope :for_user, lambda { |user| where(["party_id = ?", user.party_id]) }

  scope :submitted_between, lambda { |from_date, thru_date|
                            includes(:pay_period)
                                .where(:status => 'submitted', :pay_periods => {:from_date => from_date.to_date..thru_date.to_date})
                          }

  scope :existing_timesheets, lambda { |from_date, party_id|
                              includes(:pay_period)
                                  .where(:party_id => party_id)
                                  .where(:pay_periods => {:from_date => from_date})
                            }

  class << self
    # get current timesheet for party with passed role
    # if no timesheet could be found it will create one
    #
    # @param party [Party] party to add
    # @param role_type [RoleType] role type to use in the association
    # @return [Timesheet] current timesheet
    def current!(party, role_type)
      pay_period = PayPeriod.current!

      statement = self.joins(:timesheet_party_roles)
                      .where('pay_period_id' => pay_period)
                      .where('timesheet_party_roles.party_id' => party)
                      .where('timesheet_party_roles.role_type_id' => role_type)

      timesheet = statement.first

      # create a new timesheet if one does not exist for the pay_period
      unless timesheet
        timesheet = Timesheet.create!(
            pay_period: pay_period
        )

        timesheet.add_party_with_role(party, role_type)
      end

      timesheet
    end
  end

  #aasm mixin
  aasm_column :status
  aasm_state :open, :initial => true
  aasm_state :submitted
  aasm_state :recalled
  aasm_state :rejected
  aasm_state :approved
  aasm_state :resubmitted

  aasm_event :submit do
    transitions :to => :submitted, :from => [:open]
  end

  aasm_event :recall do
    transitions :to => :recalled, :from => [:submitted, :resubmitted, :approved]
  end

  aasm_event :resubmit do
    transitions :to => :resubmitted, :from => [:recalled, :rejected]
  end

  aasm_event :reject do
    transitions :to => :rejected, :from => [:submitted, :resubmitted]
  end

  aasm_event :approve do
    transitions :to => :approved, :from => [:submitted, :resubmitted]
  end

  def recalled?
    self.status == 'recalled'
  end

  def rejeted?
    self.status == 'rejected'
  end

  # pass through method to get week_number on pay period
  #
  def week_number
    self.pay_period.week_number
  end

  # pass through method to get thru_date on pay period
  #
  def thru_date
    self.pay_period.thru_date
  end

  # pass through method to get from_date on pay period
  #
  def from_date
    self.pay_period.from_date
  end

  # add party with passed role to this timesheet
  #
  # @param party [Party] party to add
  # @param role_type [RoleType] role type to use in the association
  # @return [TimeSheetPartyRole] newly created relationship
  def add_party_with_role(party, role_type)
    self.timesheet_party_roles << TimesheetPartyRole.create(
        party: party,
        role_type: role_type
    )
  end

  # get total seconds for given date
  #
  # @param date [Date] date to get total hours for
  # @return [Decimal] total seconds
  def day_total_in_seconds(date)
    hours = BigDecimal.new(0)
    time_entry_arel_tbl = TimeEntry.arel_table

    self.time_entries.where(time_entry_arel_tbl[:from_datetime].gteq(date))
        .where(time_entry_arel_tbl[:from_datetime].lteq((date + 1.day))).each do |time_entry|
      hours += ((time_entry.regular_hours_in_seconds || 0) + (time_entry.overtime_hours_in_seconds || 0))
    end

    hours
  end

  # get total for a given day formatted as HH:MM:SS
  #
  # @param date [Date] date to get total hours for
  # @return [String] HH:MM:SS
  def day_total_formatted(date)
    Time.at(day_total_in_seconds(date)).utc.strftime("%H:%M:%S")
  end

  # get total seconds for timesheet
  #
  # @return [Decimal] total seconds
  def total_in_seconds
    hours = BigDecimal.new(0)

    self.time_entries.each do |time_entry|
      hours += ((time_entry.regular_hours_in_seconds || 0) + (time_entry.overtime_hours_in_seconds || 0))
    end

    hours
  end

  # get total formatted as HH:MM:SS
  #
  # @param date [Date] date to get total hours for
  # @return [String] HH:MM:SS
  def total_formatted
    Time.at(total_in_seconds).utc.strftime("%H:%M:%S")
  end

end