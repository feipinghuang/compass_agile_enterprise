class BaseProducts < ActiveRecord::Migration
  def self.up

    # product_types
    unless table_exists?(:product_types)
      create_table :product_types do |t|
        #these columns are required to support the behavior of the plugin 'better_nested_set'
        #ALL products have the ability to act as packages in a nested set-type structure
        #
        #The package behavior is treated differently from other product_relationship behavior
        #which is implemented using a standard relationship structure.
        #
        #This is to allow quick construction of highly nested product types.
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here   
        t.column :description, :string
        t.column :product_type_record_id, :integer
        t.column :product_type_record_type, :string
        t.column :external_identifier, :string
        t.column :internal_identifier, :string
        t.column :external_id_source, :string
        t.column :default_image_url, :string
        t.column :list_view_image_id, :integer
        t.column :type, :string
        t.string :sku
        t.text :comment
        t.references :unit_of_measurement
        t.timestamps
      end

      add_index :product_types, :parent_id, :name => "prod_type_parent_id_idx"
      add_index :product_types, :lft, :name => "prod_type_lft_idx"
      add_index :product_types, :rgt, :name => "prod_type_rgt_idx"
      add_index :product_types, :unit_of_measurement_id, :name => "prod_type_uom_idx"
      add_index :product_types, [:product_type_record_id, :product_type_record_type], :name => "prod_type_poly_idx"
    end

    # product_instances
    unless table_exists?(:product_instances)
      create_table :product_instances do |t|
        #these columns are required to support the behavior of the plugin 'better_nested_set'
        #ALL products have the ability to act as packages in a nested set-type structure
        #
        #The package behavior is treated differently from other product_relationship behavior
        #which is implemented using a standard relationship structure.
        #
        #This is to allow quick construction of highly nested product types.
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here   
        t.column :description, :string
        t.column :product_instance_record_id, :integer
        t.column :product_instance_record_type, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.column :product_type_id, :integer
        t.column :type, :string

        t.references :prod_availability_status_type

        t.timestamps
      end

      add_index :product_instances, :parent_id, :name => "prod_ins_parent_id_idx"
      add_index :product_instances, :lft, :name => "prod_ins_lft_idx"
      add_index :product_instances, :rgt, :name => "prod_ins_rgt_idx"
      add_index :product_instances, [:product_instance_record_id, :product_instance_record_type], :name => "prod_ins_poly_idx"
      add_index :product_instances, :product_type_id, :name => "prod_ins_prod_type_idx"
    end

    # product_offers
    unless table_exists?(:product_offers)
      create_table :product_offers do |t|
        t.references :product_offer_record, :polymorphic => true

        t.string :description
        t.string :external_identifier
        t.string :external_id_source
        t.date :valid_from
        t.date :valid_to

        t.timestamps
      end

      add_index :product_offers, [:product_offer_record_id, :product_offer_record_type], :name => "prod_offer_poly_idx"
      add_index :product_offers, :valid_from, :name => "prod_offer_valid_from_idx"
      add_index :product_offers, :valid_to, :name => "prod_offer_valid_to_idx"
    end

    # simple_product_offers
    unless table_exists?(:simple_product_offers)
      create_table :simple_product_offers do |t|
        t.references :product_type

        t.string :description, :string
        t.decimal :base_price, :precision => 8, :scale => 2
        t.integer :uom

        t.timestamps
      end

      add_index :simple_product_offers, :product_type_id, :name => "simple_prod_offer_product_type_id_idx"
    end

    # prod_instance_reln_types
    unless table_exists?(:prod_instance_reln_types)
      create_table :prod_instance_reln_types do |t|
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here   
        t.column :description, :string
        t.column :comments, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end

      add_index :prod_instance_reln_types, :parent_id, :name => "prod_reln_type_parent_id_idx"
      add_index :prod_instance_reln_types, :lft, :name => "prod_reln_type_lft_idx"
      add_index :prod_instance_reln_types, :rgt, :name => "prod_reln_type_rgt_idx"
    end

    # prod_instance_role_types
    unless table_exists?(:prod_instance_role_types)
      create_table :prod_instance_role_types do |t|
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer
        #custom columns go here   
        t.column :description, :string
        t.column :comments, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end

      add_index :prod_instance_role_types, :parent_id, :name => "prod_ins_role_type_parent_id_idx"
      add_index :prod_instance_role_types, :lft, :name => "prod_ins_role_type_lft_idx"
      add_index :prod_instance_role_types, :rgt, :name => "prod_ins_role_type_rgt_idx"
    end

    # prod_instance_relns
    unless table_exists?(:prod_instance_relns)
      create_table :prod_instance_relns do |t|
        t.column :prod_instance_reln_type_id, :integer
        t.column :description, :string
        t.column :prod_instance_id_from, :integer
        t.column :prod_instance_id_to, :integer
        t.column :role_type_id_from, :integer
        t.column :role_type_id_to, :integer
        t.column :from_date, :date
        t.column :thru_date, :date
        t.timestamps
      end

      add_index :prod_instance_relns, :prod_instance_reln_type_id, :name => "prod_instance_relns_type_idx"
      add_index :prod_instance_relns, :prod_instance_id_from, :name => "prod_instance_relns_ins_from_idx"
      add_index :prod_instance_relns, :prod_instance_id_to, :name => "prod_instance_relns_ins_to_idx"
      add_index :prod_instance_relns, :role_type_id_from, :name => "prod_instance_relns_type_from_idx"
      add_index :prod_instance_relns, :role_type_id_to, :name => "prod_instance_relns_type_to_idx"
    end

    # prod_type_reln_types
    unless table_exists?(:prod_type_reln_types)
      create_table :prod_type_reln_types do |t|
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer
        #custom columns go here   
        t.column :description, :string
        t.column :comments, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end

      add_index :prod_instance_role_types, :parent_id, :name => "prod_type_reln_type_parent_id_idx"
      add_index :prod_instance_role_types, :lft, :name => "prod_type_reln_type_lft_idx"
      add_index :prod_instance_role_types, :rgt, :name => "prod_type_reln_type_rgt_idx"
    end

    # prod_type_role_types
    unless table_exists?(:prod_type_role_types)
      create_table :prod_type_role_types do |t|
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer
        #custom columns go here   
        t.column :description, :string
        t.column :comments, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end

      add_index :prod_instance_role_types, :parent_id, :name => "prod_type_role_types_parent_id_idx"
      add_index :prod_instance_role_types, :lft, :name => "prod_type_role_types_lft_idx"
      add_index :prod_instance_role_types, :rgt, :name => "prod_type_role_types_rgt_idx"
    end

    # prod_type_relns
    unless table_exists?(:prod_type_relns)
      create_table :prod_type_relns do |t|
        t.column :prod_type_reln_type_id, :integer
        t.column :description, :string
        t.column :prod_type_id_from, :integer
        t.column :prod_type_id_to, :integer
        t.column :role_type_id_from, :integer
        t.column :role_type_id_to, :integer
        t.column :status_type_id, :integer
        t.column :from_date, :date
        t.column :thru_date, :date
        t.timestamps
      end

      add_index :prod_type_relns, :prod_type_reln_type_id, :name => "prod_type_relns_type_idx"
      add_index :prod_type_relns, :prod_type_id_from, :name => "prod_type_relns_type_from_idx"
      add_index :prod_type_relns, :prod_type_id_to, :name => "prod_type_relns_type_to_idx"
      add_index :prod_type_relns, :role_type_id_from, :name => "prod_type_relns_role_from_idx"
      add_index :prod_type_relns, :role_type_id_to, :name => "prod_type_relns_role_to_idx"
    end

    # prod_availability_status_types
    unless table_exists?(:prod_availability_status_types)
      create_table :prod_availability_status_types do |t|
        #better nested set colummns
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        t.column :description, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string

        t.timestamps
      end

      add_index :prod_availability_status_types, :parent_id, :name => "prod_avail_status_types_parent_id_idx"
      add_index :prod_availability_status_types, :lft, :name => "prod_avail_status_types_lft_idx"
      add_index :prod_availability_status_types, :rgt, :name => "prod_avail_status_types_rgt_idx"
    end

    # product_type_pty_roles
    unless table_exists?(:product_type_pty_roles)
      create_table :product_type_pty_roles do |t|
        t.references :party
        t.references :role_type
        t.references :product_type

        t.timestamps
      end

      add_index :product_type_pty_roles, :party_id, :name => "product_type_pty_roles_party_idx"
      add_index :product_type_pty_roles, :role_type_id, :name => "product_type_pty_roles_role_idx"
      add_index :product_type_pty_roles, :product_type_id, :name => "product_type_pty_roles_prod_type_idx"
    end

    # product_features
    unless table_exists?(:product_feature_types)
      create_table :product_feature_types do |t|

        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.string :description
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id

        t.timestamps
      end
    end

    # product_feature_applicabilities
    unless table_exists?(:product_feature_applicabilities)
      create_table :product_feature_applicabilities do |t|
        t.references :feature_of_record, :polymorphic => true
        t.references :product_feature

        t.boolean :is_mandatory

        t.timestamps
      end

      add_index :product_feature_applicabilities, [:feature_of_record_type, :feature_of_record_id], :name => 'prod_feature_record_idx'
    end

    # product_feature_type_product_feature_values
    unless table_exists?(:product_feature_type_product_feature_values)
      create_table :product_feature_type_product_feature_values do |t|
        t.references :product_feature_type
        t.references :product_feature_value

        t.timestamps
      end

      add_index :product_feature_type_product_feature_values, :product_feature_type_id, :name => 'prod_feature_type_feature_value_type_idx'
      add_index :product_feature_type_product_feature_values, :product_feature_value_id, :name => 'prod_feature_type_feature_value_value_idx'
    end

    # product_features
    unless table_exists?(:product_features)
      create_table :product_features do |t|
        t.references :product_feature_type
        t.references :product_feature_value

        t.timestamps
      end

      add_index :product_features, :product_feature_type_id, :name => 'prod_feature_type_idx'
      add_index :product_features, :product_feature_value_id, :name => 'prod_feature_value_idx'
    end

    # product_feature_values
    unless table_exists?(:product_feature_values)
      create_table :product_feature_values do |t|
        t.string :value
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source
        t.string :description

        t.timestamps
      end
    end

    # product_feature_interactions
    unless table_exists?(:product_feature_interactions)
      create_table :product_feature_interactions do |t|
        t.references :product_feature
        t.references :interacted_product_feature
        t.references :product_feature_interaction_type

        t.timestamps
      end

      add_index :product_feature_interactions, :product_feature_id, :name => 'prod_feature_int_feature_idx'
      add_index :product_feature_interactions, :interacted_product_feature_id, :name => 'prod_feature_int_interacted_feature_idx'
      add_index :product_feature_interactions, :product_feature_interaction_type_id, :name => 'prod_feature_int_interacted_feature_type_idx'
    end

    # product_feature_interaction_types
    unless table_exists?(:product_feature_interaction_types)
      create_table :product_feature_interaction_types do |t|
        t.string :internal_identifier
        t.string :description

        t.timestamps
      end
    end
  end

  def self.down
    [
        :prod_type_relns, :prod_type_role_types, :prod_type_reln_types,
        :prod_instance_relns, :prod_instance_role_types, :prod_instance_reln_types,
        :simple_product_offers, :product_offers, :product_instances,
        :product_types, :prod_availability_status_types, :product_type_pty_roles,
        :product_features, :product_feature_type_product_feature_values,
        :product_feature_applicabilities, :product_features, :product_feature_values,
        :product_feature_interactions, :product_feature_interaction_types
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
