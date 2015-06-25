class AddTaxableToProductTypes < ActiveRecord::Migration
  def change
    add_column :product_types, :taxable, :boolean
  end
end
