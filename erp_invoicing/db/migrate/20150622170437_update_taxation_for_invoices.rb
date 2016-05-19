class UpdateTaxationForInvoices < ActiveRecord::Migration
  def up

    if column_exists? :invoice_items, :tax_rate
      remove_column :invoice_items, :tax_rate
    end

    unless column_exists? :invoice_items, :sales_tax
      add_column :invoice_items, :sales_tax, :decimal, precision: 8, scale: 2
    end

    unless column_exists? :invoice_items, :taxed
      add_column :invoice_items, :taxed, :boolean
    end

    if column_exists? :invoice_items, :taxable
      remove_column :invoice_items, :taxable
    end

    unless column_exists? :invoices, :sales_tax
      add_column :invoices, :sales_tax, :decimal, precision: 8, scale: 2
    end

  end

  def down

    unless column_exists? :invoice_items, :tax_rate
      add_column :invoice_items, :tax_rate, :decimal, precision: 8, scale: 2
    end

    if column_exists? :invoice_items, :sales_tax
      remove_column :invoice_items, :sales_tax
    end

    if column_exists? :invoice_items, :taxed
      remove_column :invoice_items, :taxed
    end

    unless column_exists? :invoice_items, :taxable
      add_column :invoice_items, :taxable, :boolean
    end

    if column_exists? :invoices, :sales_tax
      remove_column :invoices, :sales_tax
    end

  end

end
