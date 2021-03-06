class AddUnitPriceToOrderLineItems < ActiveRecord::Migration
  def change
    add_column :order_line_items, :unit_price, :decimal unless column_exists?(:order_line_items, :unit_price)
  end
end
