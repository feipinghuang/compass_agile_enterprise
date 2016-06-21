class AddProductOptions < ActiveRecord::Migration
  def up

    unless table_exists? :product_option_types
      create_table :product_option_types do |t|
        t.string :description
        t.string :internal_identifier

        t.string :selection_type

        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.references :tenant

        t.text :custom_fields

        t.references :created_by
        t.references :updated_by

        t.timestamps
      end

      add_index :product_option_types, :internal_identifier, :name => 'prod_opt_types_iid_idx'
      add_index :product_option_types, :selection_type, :name => 'prod_opt_types_selection_type_idx'
      add_index :product_option_types, [:parent_id, :lft, :rgt], :name => 'prod_opt_types_nested_idx'
      add_index :product_option_types, :tenant_id, :name => 'prod_opt_types_tenant_id_idx'
    end

    unless table_exists? :product_options
      create_table :product_options do |t|
        t.references :product_option_value
        t.references :product_option_type

        t.string :description
        t.string :internal_identifier

        t.references :created_by
        t.references :updated_by

        t.timestamps
      end

      add_index :product_options, :product_option_value_id, :name => 'prod_opt_value_idx'
      add_index :product_options, :product_option_type_id, :name => 'prod_opt_type_idx'
      add_index :product_options, :internal_identifier, :name => 'prod_opt_iid_idx'
    end

    unless table_exists? :product_option_applicabilities
      create_table :product_option_applicabilities do |t|
        t.references :optioned_record, :polymorphic => true
        t.references :product_option_type
      
        t.string :description
        t.boolean :required
        t.boolean :multi_select
        t.boolean :enabled, default: true
      
        t.references :created_by
        t.references :updated_by
      
        t.timestamps
      end
      
      add_index :product_option_applicabilities, [:optioned_record_type, :optioned_record_id], :name => 'prod_opt_appl_optioned_record_idx'
      add_index :product_option_applicabilities, :product_option_type_id, :name => 'prod_opt_appl_opt_type_idx'
    end

    unless table_exists? :selected_product_options
      create_table :selected_product_options do |t|
        t.references :product_option_applicability
        t.references :selected_option_record, polymorphic: true

        t.timestamps
      end

      add_index :selected_product_options, :product_option_applicability_id, :name => 'sel_prod_opt_applicability_idx'
      add_index :selected_product_options, [:selected_option_record_type, :selected_option_record_id], :name => 'sel_prod_opt_record_idx'
    end

    unless table_exists? :product_options_selected_product_options
      create_table :product_options_selected_product_options, id: false do |t|
        t.references :product_option
        t.references :selected_product_option
      end

      add_index :product_options_selected_product_options, :product_option_id, :name => 'prod_opt_sel_prod_opt_opt_idx'
      add_index :product_options_selected_product_options, :selected_product_option_id, :name => 'prod_opt_sel_prod_opt_sel_prod_opt_idx'
    end

  end

  def down
    %w{product_option_types product_options product_option_applicabilities selected_product_options product_options_selected_product_options}.each do |table|
      if table_exists? table
        drop_table table
      end
    end
  end
end
