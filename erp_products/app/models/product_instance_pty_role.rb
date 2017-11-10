class ProductInstancePtyRole < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :party
  belongs_to :product_instance
  belongs_to :role_type
end
