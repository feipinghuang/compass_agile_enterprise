class ProductOfferProductType < ActiveRecord::Base
  # create_table :product_offer_product_types do |t|
  #
  #   t.column :product_type_id, :integer
  #   t.column :product_offer_id, :integer
  #   t.timestamps
  # end
  #
  # add_index :product_offer_product_types, :product_type_id, :name => "prod_offer_prod_type_prod_type_id_idx"
  # add_index :product_offer_product_types, :product_offer_id, :name => "prod_offer_prod_offer_prod_offer_id_idx"


  attr_protected :created_at, :updated_at

  belongs_to :product_type
  belongs_to :product_offer


end