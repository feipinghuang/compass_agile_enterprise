# create_table :product_options do |t|
#   t.references :product_option_value
#   t.references :product_option_type
#
#   t.string :description
#   t.string :internal_identifier
#
#   t.references :created_by
#   t.references :updated_by
#
#   t.timestamps
# end
#
# add_index :product_options, :product_option_value_id, :name => 'prod_opt_value_idx'
# add_index :product_options, :product_option_type_id, :name => 'prod_opt_type_idx'
# add_index :product_options, :internal_identifier, :name => 'prod_opt_iid_idx'

class ProductOption < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  has_and_belongs_to_many :selected_product_options

  belongs_to :product_option_type
  alias :type :product_option_type

  belongs_to :product_option_value
  alias :value :product_option_value

  def to_data_hash

  	to_hash(only: [:id, :description, :internal_identifier])

  end
  alias :to_mobile_data_hash :to_data_hash

end
