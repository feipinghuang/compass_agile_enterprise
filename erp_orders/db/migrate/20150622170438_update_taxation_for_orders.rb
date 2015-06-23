class UpdateTaxationForOrders < ActiveRecord::Migration
  def up

    unless column_exists? :order_line_items, :sales_tax
      add_column :order_line_items, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :order_txns, :sales_tax
      add_column :order_txns, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :charge_lines, :sales_tax
      add_column :charge_lines, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :charge_lines, :taxable
      add_column :charge_lines, :taxable, :boolean
    end

  end

  def down

    if column_exists? :order_line_items, :sales_tax
      remove_column :order_line_items, :sales_tax
    end

    if column_exists? :order_txns, :sales_tax
      remove_column :order_txns, :sales_tax
    end

    if column_exists? :charge_lines, :sales_tax
      remove_column :charge_lines, :sales_tax
    end

    if column_exists? :charge_lines, :taxable
      remove_column :charge_lines, :taxable
    end

  end

end
