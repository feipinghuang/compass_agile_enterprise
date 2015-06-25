class SalesTaxPolicy < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type

  has_many :sales_tax_lines
end