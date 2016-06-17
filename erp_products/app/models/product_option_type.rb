# create_table :product_option_types do |t|
#   t.string :description
#   t.string :internal_identifier
#
#   t.integer :parent_id
#   t.integer :lft
#   t.integer :rgt
#
#   t.references :created_by
#   t.references :updated_by
#
#   t.timestamps
# end
#
# add_index :product_option_types, :internal_identifier, :name => 'prod_opt_types_iid_idx'

class ProductOptionType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :product_options
end
