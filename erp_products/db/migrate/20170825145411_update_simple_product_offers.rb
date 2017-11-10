class UpdateSimpleProductOffers < ActiveRecord::Migration

  def up
    unless table_exists?(:simple_product_offers)
      create_table :simple_product_offers do |t|
        t.string      :description
        t.references  :unit_of_measurement
        t.string      :internal_identifier
        t.string      :external_identifier
        t.string      :external_id_source
        t.string      :custom_fields

        t.timestamps
      end
    else
      if column_exists? :simple_product_offers, :product_type_id
        remove_column :simple_product_offers, :product_type_id
      end
      if column_exists? :simple_product_offers, :string
        remove_column :simple_product_offers, :string
      end
      if column_exists? :simple_product_offers, :uom
        remove_column :simple_product_offers, :uom
      end
      add_column :simple_product_offers, :unit_of_measurement_id, :integer, :default => nil unless column_exists? :simple_product_offers, :unit_of_measurement_id
      add_column :simple_product_offers, :internal_identifier, :string, :default => nil unless column_exists? :simple_product_offers, :internal_identifier
      add_column :simple_product_offers, :external_identifier, :string, :default => nil unless column_exists? :simple_product_offers, :external_identifier
      add_column :simple_product_offers, :external_id_source, :string, :default => nil unless column_exists? :simple_product_offers, :external_id_source
    end
  end

  def down
    if table_exists?(:simple_product_offers)
      drop_table :simple_product_offers
    end
  end

end
