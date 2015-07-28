# create_table :product_feature_type_product_feature_values do |t|
#   t.references :product_feature_type
#   t.references :product_feature_value
#
#   t.timestamps
# end
#
# add_index :product_feature_type_product_feature_values, :product_feature_type_id, :name => 'prod_feature_type_feature_value_type_idx'
# add_index :product_feature_type_product_feature_values, :product_feature_value_id, :name => 'prod_feature_type_feature_value_value_idx'#

class ProductFeatureTypeProductFeatureValue < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :product_feature_type
  belongs_to :product_feature_value
end
