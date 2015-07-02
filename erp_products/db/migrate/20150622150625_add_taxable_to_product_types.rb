class AddTaxableToProductTypes < ActiveRecord::Migration
  def change
    add_column :product_types, :taxable, :boolean unless column_exists? :product_types, :taxable
  end
end
