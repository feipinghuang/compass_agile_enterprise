class UpdateProductOffers < ActiveRecord::Migration
  def up
    if column_exists? :product_offers, :valid_from
      remove_column :product_offers, :valid_from
    end
    if column_exists? :product_offers, :valid_to
      remove_column :product_offers, :valid_to
    end
    add_column :product_offers, :product_type_id, :integer, :default => nil unless column_exists? :product_offers, :product_type_id
    add_column :product_offers, :discount_id, :integer, :default => nil unless column_exists? :product_offers, :discount_id
  end

  def down
  end
end
