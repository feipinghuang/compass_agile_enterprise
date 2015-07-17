# create_table :product_feature_interactions do |t|
#   t.references :product_feature
#   t.references :interacted_product_feature
#   t.references :product_feature_interaction_type
#
#   t.timestamps
# end
#
# add_index :product_feature_interactions, :product_feature_id, :name => 'prod_feature_int_feature_idx'
# add_index :product_feature_interactions, :interacted_product_feature_id, :name => 'prod_feature_int_interacted_feature_idx'
# add_index :product_feature_interactions, :product_feature_interaction_type_id, :name => 'prod_feature_int_interacted_feature_type_idx'

class ProductFeatureInteraction < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :product_feature_from, class_name: "ProductFeature"
  belongs_to :product_feature_to, class_name: "ProductFeature"
  belongs_to :product_feature_interaction_type

  is_json :custom_fields
end
