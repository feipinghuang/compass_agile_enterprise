class ProductCollection < ActiveRecord::Base
  # create_table :product_collections do |t|
  #   t.string      :description
  #   t.references  :collections
  #   t.references  :product_types
  #
  #   t.timestamps

  attr_protected :created_at, :updated_at

  belongs_to :product_type
  belongs_to :collection

end