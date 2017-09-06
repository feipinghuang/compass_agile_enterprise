class Discount < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  # create_table :discounts do |t|
  #   t.string    :description
  #   t.string    :discount_type
  #   t.decimal   :amount
  #   t.boolean   :date_constrained
  #   t.datetime  :valid_from
  #   t.datetime  :valid_thru
  #   t.boolean   :round
  #   t.decimal   :round_amount
  #   t.integer   :created_by_party_id
  #   t.integer   :updated_by_party_id
  #
  #   t.timestamps
  #

  has_many :product_offers, dependent: :destroy
  has_many :product_type_discounts, dependent: :destroy
  has_many :product_types, through: :product_type_discounts

  validates :description, :uniqueness => true, :allow_nil => false


  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      unless statement
        statement = Discount
      end

      if filters[:id]
        statement = statement.where(id: filters[:id])
      end

      if filters and filters[:keyword]
        discount_tbl = self.arel_table
        statement = statement.where(discount_tbl[:description].matches('%' + filters[:keyword] + '%'))
      end

      statement
    end
  end

  # take array of product types and generate a set of product offers
  def generate_product_offers(product_type_ids)

    # TODO: Ask Rick about aging discounts / history of discounts

    # TODO: For now, going to delete all product offers and re-generate
    product_type_discounts.each do |product_type_discount|
      product_type_discount.destroy
      end
    product_offers.each do |product_offer|
      product_offer.destroy
    end
    # TODO: Revisit this

    product_type_ids.each do |product_type_id|
      # tie the product type to the discount
      ProductTypeDiscount.create(
          discount_id: id,
          product_type_id: product_type_id.to_i
      )

      # create a simple product offer
      simple_product_offer = SimpleProductOffer.create(
      )


      # create a product offer
      ProductOffer.create(
          product_offer_record_id: simple_product_offer.id,
          product_offer_record_type: 'SimpleProductOffer',
          description: 'P OFFER ' + product_type_id,
          product_type_id: product_type_id.to_i,
          discount_id: id
      )

      # calculate the discount price, based on type and amount
      # get current non-discounted price forthe product
      product_type_base_price = ProductType.find(product_type_id.to_i).get_current_simple_plan.money_amount
      case discount_type.downcase
        when 'amount'
          new_price = product_type_base_price - amount
        when 'percent'
          new_price = product_type_base_price - (amount * product_type_base_price)
        when 'rule_based'
          # tbd
          new_price = 0.0
      end
      if round
        new_price = new_price.floor + round_amount
      end


      # create a pricing plan
      pricing_plan = PricingPlan.create(
          description: 'PP OFFER ' + product_type_id,
          from_date: valid_from,
          thru_date: valid_thru,
          is_simple_amount: true,
          money_amount: new_price
      )


      # create pricing plan assignment
      PricingPlanAssignment.create(
          pricing_plan_id:   pricing_plan.id,
          priceable_item_type: 'SimpleProductOffer',
          priceable_item_id: simple_product_offer.id
      )

    end


  end

  def to_data_hash
    data = to_hash(only: [
                       :id,
                       :description,
                       :discount_type,
                       :amount,
                       :date_constrained,
                       :valid_from,
                       :valid_thru,
                       :round,
                       :round_amount,
                       :created_at,
                       :updated_at
                   ])

    # TODO: add offers, product types. and prices??
    product_types = []
    product_offers.each do |product_offer|
      product_type_info = {}
      product_type = ProductType.find(product_offer.product_type_id)
      product_type_info[:product_type_id] = product_type.id
      product_type_info[:product_type_description] = product_type.description
      product_type_info[:product_type_sku] = product_type.sku
      product_type_info[:product_type_base_price] = '%.2f' % product_type.get_current_simple_plan.money_amount
      product_type_info[:product_type_discount_price] = '%.2f' % product_offer.product_offer_record.get_current_simple_plan.money_amount
      product_types << product_type_info
    end

    data[:product_types] = product_types

    data
  end

  def to_mobile_hash
    to_data_hash
  end

end