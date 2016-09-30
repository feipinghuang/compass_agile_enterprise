class BaseInventory < ActiveRecord::Migration
  def self.up

    unless table_exists?(:inventory_entries)
      create_table :inventory_entries do |t|
        t.column :description, :string
        t.column :inventory_entry_record_id, :integer
        t.column :inventory_entry_record_type, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.column :product_type_id, :integer
        t.column :number_available, :integer
        t.string :sku
        t.integer :number_sold
        t.references :unit_of_measurement
        t.integer :number_in_stock

        t.timestamps
      end

      add_index :inventory_entries, :unit_of_measurement_id, :name => 'inv_entry_uom_idx'
      add_index :inventory_entries, [:inventory_entry_record_id, :inventory_entry_record_type], :name => "bii_1"
      add_index :inventory_entries, :product_type_id
    end

    unless table_exists?(:inv_entry_reln_types)
      create_table :inv_entry_reln_types do |t|
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

      add_index :inv_entry_reln_types, :parent_id
    end

    unless table_exists?(:inv_entry_role_types)
      create_table :inv_entry_role_types do |t|
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

      add_index :inv_entry_role_types, :parent_id
    end

    unless table_exists?(:inv_entry_relns)
      create_table :inv_entry_relns do |t|
        t.column :inv_entry_reln_type_id, :integer
        t.column :description, :string
        t.column :inv_entry_id_from, :integer
        t.column :inv_entry_id_to, :integer
        t.column :role_type_id_from, :integer
        t.column :role_type_id_to, :integer
        t.column :status_type_id, :integer
        t.column :from_date, :date
        t.column :thru_date, :date

        t.timestamps
      end

      add_index :inv_entry_relns, :inv_entry_reln_type_id
      add_index :inv_entry_relns, :status_type_id
    end

    unless table_exists?(:prod_instance_inv_entries)
      create_table :prod_instance_inv_entries do |t|
        t.column :product_instance_id, :integer
        t.column :inventory_entry_id, :integer

        t.timestamps
      end

      add_index :prod_instance_inv_entries, :product_instance_id
      add_index :prod_instance_inv_entries, :inventory_entry_id
    end

    unless table_exists?(:inventory_entry_locations)
      create_table :inventory_entry_locations do |t|

        t.references :inventory_entry
        t.references :facility
        t.datetime :valid_from
        t.datetime :valid_thru

        t.timestamps
      end

      add_index :inventory_entry_locations, :inventory_entry_id, :name => "inv_entry_loc_inv_entry_idx"
      add_index :inventory_entry_locations, :facility_id, :name => "inv_entry_loc_facility_idx"
    end
  end

  def self.down
    [
        :prod_instance_inv_entries,:inv_entry_relns,
        :inv_entry_role_types, :inv_entry_reln_types,
        :inventory_entries, :inventory_entry_locations
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end

end
