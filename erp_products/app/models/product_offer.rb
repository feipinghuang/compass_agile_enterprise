class ProductOffer < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :product_type
  belongs_to :discount

  belongs_to :product_offer_record, :polymorphic => true

  before_destroy :before_destroy

  after_destroy :after_destroy

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)


      unless statement
        statement = ProductOffer
      end

      if filters[:id]
        statement = statement.where(id: filters[:id])
      end

      if filters[:discount_id]
        statement = statement.where(discount_id: filters[:discount_id])
      end

      if filters[:product_type_id]
        statement = statement.where(product_type_id: filters[:product_type_id])
      end


      if filters and filters[:keyword]
        like_keyword = "%#{filters[:keyword]}%"
        statement = statement.where("description LIKE ?", like_keyword)
      end

      statement
    end
  end

  def before_destroy
    # get rid of the association that ties product type and discount for this offer
    ProductTypeDiscount.where('discount_id = ? and product_type_id = ?', discount_id, product_type_id).first.delete
  end

  def after_destroy
    if self.product_offer_record && !self.product_offer_record.frozen?
      self.product_offer_record.destroy
    end 
  end

  def taxable?
    self.product_offer_record.taxable?
  end

  def to_data_hash
    if product_type.images.empty?
      image_url =  "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{Rails.configuration.assets.prefix}/place_holder.jpeg"
    else
      image_url = product_type.images.first.fully_qualified_url
    end

    data = to_hash(only: [
                       :id,
                       :discount_id,
                       :description,
                       :product_type_id,
                       :created_at,
                       :updated_at
                   ],
                   product_sku: product_type.is_base ? 'base' : product_type.sku,
                   product_description: product_type.description,
                   product_base_price: product_type.get_current_simple_plan.money_amount,
                   product_default_image_url: image_url,
                   product_is_base: product_type.is_base,
                   product_discount_price: product_offer_record.get_current_simple_plan.money_amount)

    data
  end

  def to_display_hash
    {
        id: id,
        description: description,
        product_description: product_type.description,
        product_base_price: product_type.get_current_simple_plan.money_amount,
        product_default_image_url: image_url,
        product_discount_price: product_offer_record.get_current_simple_plan.money_amount
    }
  end

  def to_mobile_hash
    to_data_hash
  end


  
end
