class ProductTypeDiscount < ActiveRecord::Base
  # create_table :product_type_discounts do |t|
  #   t.integer   :discount_id
  #   t.integer   :product_type_id
  #
  #   t.timestamps

  attr_protected :created_at, :updated_at

  belongs_to :discount
  belongs_to :product_type

end