class ProductOffer < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :product_type
  belongs_to :discount

  belongs_to :product_offer_record, :polymorphic => true


  def after_destroy
    if self.product_offer_record && !self.product_offer_record.frozen?
      self.product_offer_record.destroy
    end 
  end

  def taxable?
    self.product_offer_record.taxable?
  end


  
end
