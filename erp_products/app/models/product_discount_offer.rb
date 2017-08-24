class ProductDiscountOffer < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_json :custom_fields
  # i.e., a product offer record
  acts_as_product_offer

end
