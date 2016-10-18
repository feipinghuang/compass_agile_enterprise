class AddPositionToProductOptionApplicability < ActiveRecord::Migration
  def up
    unless column_exists? :product_option_applicabilities, :position
      add_column :product_option_applicabilities, :position, :integer, default: 0

      add_index :product_option_applicabilities, :position, name: 'product_opts_applicability_pos_idx'
    end
  end

  def down
    if column_exists? :product_option_applicabilities, :position
      remove_column :product_option_applicabilities, :position
    end
  end
end
