class UpdateProductFeatureInteractions < ActiveRecord::Migration
  def up
    rename_column :product_feature_interactions, :product_feature_id, :product_feature_from_id unless column_exists? :product_feature_interactions, :product_feature_from_id
    rename_column :product_feature_interactions, :interacted_product_feature_id, :product_feature_to_id unless column_exists? :product_feature_interactions, :product_feature_to_id

    add_index :product_feature_values, :internal_identifier, :name => 'product_ft_vals_iid_idx' unless index_exists? :product_feature_values, name: 'product_ft_vals_iid_idx'
    add_index :product_feature_interaction_types, :internal_identifier, name: 'product_ft_int_types_iid_idx' unless index_exists? :product_feature_interaction_types, name: 'product_ft_int_types_iid_idx'
    add_index :product_feature_types, :internal_identifier, name: 'product_ft_types_iid_idx' unless index_exists? :product_feature_types, name: 'product_ft_types_iid_idx'
    add_index :product_feature_types, [:rgt, :lft, :parent_id], name: 'product_ft_types_nested_set_idx' unless index_exists? :product_feature_types, 'product_ft_types_nested_set_idx'
  end

  def down
    rename_column :product_feature_interactions, :product_feature_from_id, :product_feature_id if column_exists? :product_feature_interactions, :product_feature_from_id
    rename_column :product_feature_interactions, :product_feature_to_id, :interacted_product_feature_id if column_exists? :product_feature_interactions, :product_feature_to_id

    remove_index :product_feature_values, name: 'product_ft_vals_iid_idx' if index_exists? :product_feature_values, 'product_ft_vals_iid_idx'
    remove_index :product_feature_interaction_types, name: 'product_ft_int_types_iid_idx' if index_exists? :product_feature_interaction_types, 'product_ft_int_types_iid_idx'
    remove_index :product_feature_types, name: 'product_ft_types_iid_idx' if index_exists? :product_feature_types, 'product_ft_types_iid_idx'
    remove_index :product_feature_types, name: 'product_ft_types_nested_set_idx' if index_exists? :product_feature_types, 'product_ft_types_nested_set_idx'
  end
end
