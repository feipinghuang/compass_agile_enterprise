class AddTaxPolicy < ActiveRecord::Migration
  def up

    #
    # Stores tax rates determined from external system
    #
    unless table_exists? :sales_tax_lines
      create_table :sales_tax_lines do |t|
        t.references :sales_tax_policies
        t.decimal :rate, precision: 8, scale: 2
        t.text :comment
        t.references :taxed_record, polymorphic: true

        t.timestamps
      end
    end

    #
    # Federal Sales Tax
    # State Sales Tax
    # Local Sales Tax
    #
    unless table_exists? :sales_tax_policies
      create_table :sales_tax_policies do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
    end

  end

  def down
    [:sales_tax_lines, :sales_tax_policies].each do |table|
      if table_exists? table
        drop_table table
      end
    end
  end

end
