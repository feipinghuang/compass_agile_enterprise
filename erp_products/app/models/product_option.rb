# create_table :product_options do |t|
#   t.references :product_option_value
#   t.references :product_option_type
#
#   t.references :created_by
#   t.references :updated_by
#
#   t.timestamps
# end
#
# add_index :product_options, :product_option_value_id, :name => 'prod_opt_value_idx'
# add_index :product_options, :product_option_type_id, :name => 'prod_opt_type_idx'

class ProductOption < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :product_option_type
  alias :type :product_option_type

  belongs_to :product_option_value
  alias :value :product_option_value

end
