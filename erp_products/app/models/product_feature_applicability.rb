# create_table :product_feature_applicabilities do |t|
#   t.references :feature_of_record, :polymorphic => true
#   t.references :product_feature
#
#   t.boolean :is_mandatory
#
#   t.timestamps
# end
#
# add_index :product_feature_applicabilities, [:feature_of_record_type, :feature_of_record_id], :name => 'prod_feature_record_idx'

class ProductFeatureApplicability < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :feature_of_record, polymorphic: true
  belongs_to :product_feature
end
