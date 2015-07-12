# create_table :product_feature_interaction_types do |t|
#   t.string :internal_identifier
#   t.string :description
#
#   t.timestamps
# end
#
# add_index :product_feature_interaction_types, :internal_identifier, name: 'product_ft_int_types_iid_idx'

class ProductFeatureInteractionType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type

  has_many :product_feature_interactions, dependent: :destroy

end
