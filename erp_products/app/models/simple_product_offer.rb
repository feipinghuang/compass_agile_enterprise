class SimpleProductOffer < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_json :custom_fields
  # i.e., a product offer record
  # TODO: not sure if this mixin is needed anymore. it's pretty thin
  # acts_as_product_offer

end
