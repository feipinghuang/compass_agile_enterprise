class ProductOffer < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  has_many :product_offer_product_types, dependent: :destroy
  has_many :product_types, through: :product_offer_product_types

  belongs_to :product_offer_record, :polymorphic => true

  def valid_from=(date)
    if date.is_a? String
      write_attribute(:valid_from, date.to_date)
    else
      super
    end
  end

  def valid_to=(date)
    if date.is_a? String
      write_attribute(:valid_to, date.to_date)
    else
      super
    end
  end

  def after_destroy
    if self.product_offer_record && !self.product_offer_record.frozen?
      self.product_offer_record.destroy
    end 
  end

  def taxable?
    self.product_offer_record.taxable?
  end
  
end
