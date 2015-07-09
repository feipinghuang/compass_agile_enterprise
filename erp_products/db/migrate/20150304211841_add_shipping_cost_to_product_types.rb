class AddShippingCostToProductTypes < ActiveRecord::Migration
  def change
    unless column_exists? :product_types, :shipping_cost
      add_column :product_types, :shipping_cost, :decimal, :precision => 8, :scale => 2 unless column_exists?(:product_types, :shipping_cost)
    end
  end
end
