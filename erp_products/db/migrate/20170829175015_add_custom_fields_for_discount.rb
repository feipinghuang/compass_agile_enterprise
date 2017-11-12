class AddCustomFieldsForDiscount < ActiveRecord::Migration
  def up
    add_column :discounts, :custom_fields, :text unless column_exists?(:discounts, :custom_fields)
  end

  def down
    remove_column :discounts, :custom_fields if column_exists?(:discounts, :custom_fields)
  end
end
