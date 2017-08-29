#  create_table :pricing_plans do |t|
#
#    t.string  :description
#    t.string  :comments
#
#    t.string   :internal_identifier
#
#    t.string   :external_identifier
#    t.string   :external_id_source
#
#    t.date    :from_date
#    t.date    :thru_date
#
#    #this is here as a placeholder for an 'interpreter' or 'rule' pattern
#    t.string  :matching_rules
#    #this is here as a placeholder for an 'interpreter' or 'rule' pattern
#    t.string  :pricing_calculation
#
#    #support for simple assignment of a single money amount
#    t.boolean :is_simple_amount
#    t.integer :currency_id
#    t.decimal :money_amount, :precision => 8, :scale => 2
#
#    t.integer :tenant_id
#
#    t.timestamps
#  end

class PricingPlan < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many   :valid_price_plan_components
  has_many   :pricing_plan_components, :through => :valid_price_plan_components
  belongs_to :currency

  is_tenantable

  alias :components :pricing_plan_components

  def get_price( rule_ctx = nil )

    price = Price.new
    price.pricing_plan = self

    #first check if this is a simple amount if so get the amount.
    if self.is_simple_amount
      price.money = Money.new(:amount => self.money_amount, :currency => self.currency)

      #second check if a pricing calculation exists if so use it.
    elsif !self.pricing_calculation.nil?
      rule_ctx[:pricing_plan] = self
      rule_ctx[:price] = price
      eval(self.pricing_calculation)

      #finanlly if this is not a simple amount and has no pricing calculation use the price components associated to this plan
    else
      self.pricing_plan_components.each do |pricing_plan_component|
        price_component = pricing_plan_component.get_price_component(rule_ctx)
        price.components << price_component
      end
    end

    price.description = self.description

    price
  end

  def to_data_hash
    data = to_hash(only: [:id, :created_at, :updated_at, :description,
                          :comments, :internal_identifier, :external_identifier,
                          :external_id_source, :from_date, :thru_date, :is_simple_amount, :money_amount ])

    data[:currency] = self.currency.to_data_hash

    data
  end

end
