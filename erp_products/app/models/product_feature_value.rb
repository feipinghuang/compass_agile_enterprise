# create_table :product_feature_values do |t|
#   t.string :value
#   t.string :internal_identifier
#   t.string :external_identifier
#   t.string :external_id_source
#   t.string :description
#
#   t.timestamps
# end
#
# add_index :product_feature_values, :internal_identifier, name: 'product_ft_vals_iid_idx'

class ProductFeatureValue < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many :product_feature_type_product_feature_values, dependent: :destroy
  has_many :product_feature_types, through: :product_feature_type_product_feature_values

  has_many :product_features, dependent: :destroy

  def self.find_or_create(internal_identifier, description, product_feature_type=nil)
    product_feature_value = ProductFeatureValue.joins(:product_feature_type_product_feature_values)
                                .where(internal_identifier: internal_identifier).readonly(false).first

    unless product_feature_value
      product_feature_value = ProductFeatureValue.create(description: description,
                                                         internal_identifier: internal_identifier)

    end

    if product_feature_type
      unless product_feature_value.product_feature_types.collect(&:id).include?(product_feature_type.id)
        product_feature_value.product_feature_types << product_feature_type
        product_feature_value.save
      end
    end

    product_feature_value
  end
end
