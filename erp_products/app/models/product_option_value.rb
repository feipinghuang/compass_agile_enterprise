# create_table :product_option_values do |t|
#   t.string :description
#   t.string :internal_identifier
#
#   t.references :created_by
#   t.references :updated_by
#
#   t.timestamps
# end
#
# add_index :product_option_values, :internal_identifier, :name => 'prod_opt_values_iid_idx'

class ProductOptionValue < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by
  
  has_many :product_options
end
