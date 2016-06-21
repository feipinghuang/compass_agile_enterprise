# create_table :selected_product_options do |t|
#   t.references :product_option_type
#   t.references :selected_option_record, polymorphic: true
#
#   t.timestamps
# end
#
# add_index :selected_product_options, :product_option_type_id, :name => 'sel_prod_opt_type_idx'
# add_index :selected_product_options, [:selected_option_record_type, :selected_option_record_id], :name => 'sel_prod_opt_record_idx'

class SelectedProductOption < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :product_option_applicability
  belongs_to :selected_option_record, polymorphic: true
  has_and_belongs_to_many :product_options
  alias :selected_options :product_options

  def to_data_hash
    {
      id: id,
      product_option_applicability: product_option_applicability.to_mobile_data_hash,
      selected_options: selected_options.collect(&:to_mobile_data_hash)
    }
  end
  alias :to_mobile_data_hash :to_data_hash

end
