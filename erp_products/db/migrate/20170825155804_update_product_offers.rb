class UpdateProductOffers < ActiveRecord::Migration
  def up
    if column_exists? :product_offers, :valid_from
      remove_column :product_offers, :valid_from
    end

    if column_exists? :product_offers, :valid_to
      remove_column :product_offers, :valid_to
    end

    unless column_exists? :product_offers, :product_type_id
      add_column :product_offers, :product_type_id, :integer, :default => nil
    end

    unless column_exists? :product_offers, :discount_id
      add_column :product_offers, :discount_id, :integer, :default => nil
    end
  end

  def down
    unless column_exists? :product_offers, :valid_from
      add_column :product_offers, :valid_from, :datetime
    end

    unless column_exists? :product_offers, :valid_to
      add_column :product_offers, :valid_to, :datetime
    end

    if column_exists? :product_offers, :product_type_id
      remove_column :product_offers, :product_type_id
    end

    if column_exists? :product_offers, :discount_id
      remove_column :product_offers, :discount_id
    end
  end
end
