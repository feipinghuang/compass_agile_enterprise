class ProductInstancePtyRole < ActiveRecord::Base
  belongs_to :party
  belongs_to :product_instance
  belongs_to :role_type
end