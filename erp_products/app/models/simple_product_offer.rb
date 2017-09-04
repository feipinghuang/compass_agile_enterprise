class SimpleProductOffer < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_product_offer

  belongs_to :product_type
end
