# create_table :product_features do |t|
#   t.references :product_feature_type
#   t.references :product_feature_value
#
#   t.timestamps
# end
#
# add_index :product_features, :product_feature_type_id, :name => 'prod_feature_type_idx'
# add_index :product_features, :product_feature_value_id, :name => 'prod_feature_value_idx'

class ProductFeature < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :product_feature_type
  belongs_to :product_feature_value
  has_many :product_feature_applicabilities, dependent: :destroy

  after_destroy :destroy_interactions

  def self.find_or_create(product_feature_type, product_feature_value)
    product_feature = ProductFeature.where(product_feature_type_id: product_feature_type.id,
                                           product_feature_value_id: product_feature_value.id).first

    unless product_feature
      product_feature = ProductFeature.create(product_feature_type: product_feature_type,
                                              product_feature_value: product_feature_value)
    end

    product_feature
  end

  def self.get_feature_types(product_features)
    array = []
    already_filtered_product_features = if product_features
                                          product_features.map { |pf| pf.product_feature_type }
                                        else
                                          []
                                        end
    ProductFeatureType.each_with_level(ProductFeatureType.root.self_and_descendants) do |o, level|
      if !already_filtered_product_features.include?(o) && level != 0
        array << {feature_type: o, parent_id: o.parent_id, level: level}
      end
    end

    block_given? ? yield(array) : array
  end

  def feature_of_records
    product_feature_applicabilities.map { |o| o.feature_of_record_type.constantize.find(o.feature_of_record_id) }
  end

  def self.get_values(feature_type, product_feature=nil)
    feature_value_ids = feature_type.product_feature_values.order('description').pluck(:id)
    valid_feature_value_ids = feature_value_ids.dup

    # if there is a product feature passed then it is being scoped by that product feature and
    # we only what valid interactions
    if product_feature

      # check each possible feature type / feature value combination for the given feature_type
      feature_value_ids.each do |value_id|

        # Is there a product feature to support this feature type / feature value combination?
        test_product_feature = ProductFeature.where(product_features: {product_feature_type_id: feature_type.id, product_feature_value_id: value_id}).last

        valid_feature_value_ids -= value_id unless test_product_feature
        next unless test_product_feature

        unless test_product_feature.find_interactions(:invalid).empty?
          if test_product_feature.find_interactions(:invalid).where('product_feature_to_id = ?', product_feature.id).count == 1
            valid_feature_value_ids.delete_at(valid_feature_value_ids.index(value_id))
          end
        end

      end
    end

    valid_feature_value_ids.uniq
  end

  #
  # Product Feature Interactions
  #
  def interactions
    ProductFeatureInteraction.where('product_feature_from_id = ? or product_feature_to_id = ?', self.id, self.id)
  end

  def to_interactions
    ProductFeatureInteraction.where('product_feature_to_id = ?', self.id)
  end

  def from_interactions
    ProductFeatureInteraction.where('product_feature_from_id = ?', self.id)
  end

  # find product feature interactions by ProductFeatureInteractionsType
  def find_interactions(type)
    # look up type if iid is passed
    type = ProductFeatureInteractionType.iid(type.to_s)

    self.from_interactions.where('product_feature_interaction_type_id' => type.id)
  end

  # destroy all interactions this ProductFeature is part of
  def destroy_interactions
    self.interactions.destroy_all
  end

end
