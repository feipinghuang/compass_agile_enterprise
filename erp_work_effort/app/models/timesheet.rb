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

  has_many :time_sheet_party_roles
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

  def week_number
    self.pay_period.week_number
  end

  def thru_date
    self.pay_period.thru_date
  end

  def from_date
    self.pay_period.from_date
  end

end