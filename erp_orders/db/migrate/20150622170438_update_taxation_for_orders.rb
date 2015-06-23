class UpdateTaxationForOrders < ActiveRecord::Migration
  def up

    unless column_exists? :order_line_items, :sales_tax
      add_column :order_line_items, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :order_line_items, :taxed
      add_column :order_line_items, :taxed, :boolean
    end

    unless column_exists? :order_txns, :sales_tax
      add_column :order_txns, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :charge_lines, :sales_tax
      add_column :charge_lines, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :charge_lines, :taxed
      add_column :charge_lines, :taxed, :boolean
    end

    unless column_exists? :charge_types, :taxable
      add_column :charge_types, :taxable, :boolean
    end

  end

  def down

    if column_exists? :order_line_items, :sales_tax
      remove_column :order_line_items, :sales_tax
    end

    if column_exists? :order_line_items, :taxed
      remove_column :order_line_items, :taxed
    end

    if column_exists? :order_txns, :sales_tax
      remove_column :order_txns, :sales_tax
    end

    if column_exists? :charge_lines, :sales_tax
      remove_column :charge_lines, :sales_tax
    end

    if column_exists? :charge_types, :taxable
      remove_column :charge_types, :taxable
    end

    if column_exists? :charge_lines, :taxed
      remove_column :charge_lines, :taxed
    end

  end

end
