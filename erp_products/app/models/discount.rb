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
  #   t.integer   :round_amount
  #   t.integer   :created_by_party_id
  #   t.integer   :updated_by_party_id
  #   t.integer   :tenant_id
  #
  #   t.timestamps
  #


  is_tenantable

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

  # take array of product type ids and generate a set of product offers
  def generate_product_offers(product_type_ids, product_type_tag)

    product_type_ids.each do |product_type_id|
      # check to see if this product type already belongs to the discount
      product_type_discount = ProductTypeDiscount.find_by_discount_id_and_product_type_id(id, product_type_id)
      if product_type_discount.nil?
        # tie the product type to the discount
        ProductTypeDiscount.create(
            discount_id: id,
            product_type_id: product_type_id
        )

        # create a simple product offer
        simple_product_offer = SimpleProductOffer.create(
        )

        # update the ProductOffer created by SimpleProductOffer 'acting' as a product offer
        simple_product_offer.product_offer.description = 'P OFFER ' + product_type_id.to_s
        simple_product_offer.product_offer.product_type_id = product_type_id
        simple_product_offer.product_offer.discount_id = id
        simple_product_offer.product_offer.save

        # calculate the discount price, based on type and amount
        # get current non-discounted price forthe product
        discount_price = calculate_discount_amount(product_type_id.to_i)

        simple_product_offer.set_default_price(discount_price, currency=Currency.usd)

        # tag these products if there's a tag
        unless product_type_tag.blank?
            product_type = ProductType.find(product_type_id)
            product_type.tag_list.add(product_type_tag.to_s, parse: true)
            product_type.save
        end

      end
    end
  end

  def remove_product_offers(product_type_ids, product_type_tag)

    if product_type_ids.length == 0
      # remove all
      # if there's a tag involved grab the ids
      unless product_type_tag.blank?
        product_type_ids_to_be_untagged = product_type_discounts.collect{ |product_type| product_type.id }
      end
      product_offers_to_remove = product_offers
    else
      # remove specific
      product_type_ids_to_remove = []
      product_type_ids.each do |product_type_id|
        product_type = ProductType.find(product_type_id)
        product_type_ids_to_remove << product_type.id
        if product_type.is_base
          # remove product type's children from discount
          product_type_ids_to_remove.concat( product_type.children.collect{ |child| child.id } )
        else
          # if there are no siblings left in the offer, remove the parent too
          product_type_sibling_ids = product_type.siblings.collect{ |sibling| sibling.id }
          siblings_still_in_discount = ProductTypeDiscount.where("discount_id = ? and product_type_id in (#{product_type_sibling_ids.join(',')})",id)
          if siblings_still_in_discount.empty?
            product_type_ids_to_remove << product_type.parent.id
          end
        end
      end
      product_offers_to_remove = ProductOffer.where("discount_id = ? and product_type_id in (#{product_type_ids_to_remove.join(',')})", id)
      unless product_type_tag.blank?
        product_type.tag_list.remove(product_type_tag)
        product_type.save
      end
    end

    product_offers_to_remove.each do |product_offers|
      product_offers.destroy
    end
  end

  def update_product_offers
    product_offers.each do |product_offer|
      discount_price = calculate_discount_amount(product_offer.product_type_id)
      product_offer.product_offer_record.set_default_price(discount_price, currency=Currency.usd)
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

    data[:name] = description

    data
  end

  def to_mobile_hash
    to_data_hash
  end

  private

  def calculate_discount_amount(product_type_id)
    product_type_base_price = ProductType.find(product_type_id.to_i).get_current_simple_plan.money_amount
    case discount_type.downcase
      when 'amount'
        new_price = product_type_base_price - amount
      when 'percent'
        new_price = product_type_base_price - ((amount/100.0) * product_type_base_price)
      when 'rule_based'
        # tbd
        new_price = 0.0
    end
    if round
      new_price = new_price.floor + (round_amount / 100.0)
    end
    new_price
  end

end