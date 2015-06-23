class AddTaxPolicy < ActiveRecord::Migration
  def up

    #
    # Stores tax rates determined from external system
    #
    unless table_exists? :sales_tax_line
      create_table :sales_tax_line do |t|
        t.references :sales_tax_policy
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
    unless table_exists? :sales_tax_policy
      create_table :sales_tax_policy do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
    end

  end

  def down
    [:sales_tax_line, :sales_tax_policy].each do |table|
      if table_exists? table
        drop_table table
      end
    end
  end

end
