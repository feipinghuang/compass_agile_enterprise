class AddIsDefaultToProductOption < ActiveRecord::Migration
  def up

    unless column_exists? :product_options, :is_default
      add_column :product_options, :is_default, :boolean, default: false
    end

  end

  def down

    if column_exists? :product_options, :is_default
      remove_column :product_options, :is_default
    end

  end
end
