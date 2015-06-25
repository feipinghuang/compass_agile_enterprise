module ErpProducts
  module Shared
    class ProductFeaturesController < ActionController::Base

      def index
        product_features = []
        if params[:product_features]
          params[:product_features].each do |product_feature|
            found = ProductFeature.where(product_features: {product_feature_type_id: product_feature['type_id'].to_i, product_feature_value_id: product_feature['value_id'].to_i}).first
            product_features << found if found
          end
        end

        feature_type_arr = ProductFeature.get_feature_types(product_features)
        render :json => {results: feature_type_arr}
      end

      def get_values
        product_feature_type = params[:productFeatureTypeId] ? ProductFeatureType.find(params[:productFeatureTypeId]) : nil

        if product_feature_type
          value_ids = ProductFeature.get_values(product_feature_type, params[:productFeatures].to_a.flatten.delete_if { |o| !o.is_a? Hash })
        else
          value_ids = []
        end

        render :json => {results: value_ids.map { |id| ProductFeatureValue.find(id) }}
      end

    end # ErpProducts
  end # Shared
end # ProductFeaturesController

