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
  has_many :timesheet_party_roles

  class << self
    def current!
      today = Date.today
      pay_periods_tbl = self.arel_table

      pay_period = self.where(pay_periods_tbl[:from_date].lteq(today))
                       .where(pay_periods_tbl[:thru_date].gteq(today)).first

      # create pay_period if it does not exist from Sunday to Saturday
      # this will eventually be based on a Calender
      unless pay_period
        today = Time.now.strftime("%A")
        if today == 'Saturday'
          from_date = Chronic.parse('last Sunday')
          thru_date = today
        elsif today == 'Sunday'
          thru_date = Chronic.parse('next Saturday')
          from_date = today
        else
          thru_date = Chronic.parse('next Saturday')
          from_date = Chronic.parse('last Sunday')
        end

        pay_period = PayPeriod.create!(
            from_date: from_date,
            thru_date: thru_date,
            week_number: Time.now.strftime("%U").to_i
        )
      end

      pay_period
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
