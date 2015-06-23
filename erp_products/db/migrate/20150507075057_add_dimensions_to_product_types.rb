class AddDimensionsToProductTypes < ActiveRecord::Migration
  def change
    unless column_exists? :product_types, :length
      add_column :product_types, :length, :decimal
      add_column :product_types, :width, :decimal
      add_column :product_types, :height, :decimal
      add_column :product_types, :weight, :decimal
      add_column :product_types, :cylindrical, :boolean
      remove_column :product_types, :shipping_cost
    end
  end
end
