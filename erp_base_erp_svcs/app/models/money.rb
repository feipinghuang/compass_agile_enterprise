class Money < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :currency
  before_save :parse_currency_code

  attr_accessor :currency_code

  def to_data_hash
    data = to_hash(only: [:id, :description, :amount])

    if currency
      data[:currency] = currency.to_data_hash
    end

    data
  end

  private

  def parse_currency_code
    unless currency_code.blank?
      case currency_code.downcase
      # Check for all iso currency types we support
      when "usd" then self.currency = Currency.usd
        # add additional currency types
      end
    end
  end
  
end
