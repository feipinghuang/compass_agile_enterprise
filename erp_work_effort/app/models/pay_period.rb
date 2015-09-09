# create_table :pay_periods do |t|
#   t.date :from_date
#   t.date :thru_date
#   t.integer :week_number
#
#   t.timestamps
# end

class PayPeriod < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  has_many :timesheets

  class << self
    def current
      today = Date.today
      pay_periods_tbl = self.arel_table

      self.where(pay_periods_tbl[:from_date].lteq(today))
          .where(pay_periods_tbl[:thru_date].gteq(today)).first
    end

    def is_end_of_pay_period?(date)
      pay_period = self.current
      pay_period.nil? ? false : (pay_period.thru_date == date)
    end
  end

  def to_s
    "[#{self.week_number}] #{self.from_date.strftime('%m/%d/%Y')} - #{self.thru_date.strftime('%m/%d/%Y')}"
  end

end
