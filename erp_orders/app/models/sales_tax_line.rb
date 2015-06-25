#  create_table :sales_tax_line do |t|
#    t.references :sales_tax_policy
#    t.decimal :rate, precision: 8, scale: 2
#    t.text :comment
#    t.references :taxed_record, polymorphic: true
#
#    t.timestamps
#  end#

class SalesTaxLine < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :taxed_record, polymorphic: true
  belongs_to :sales_tax_policy
end