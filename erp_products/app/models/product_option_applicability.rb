# create_table :product_option_applicabilities do |t|
#   t.references :optioned_record, :polymorphic => true
#   t.references :product_option_type
#
#   t.string :description
#   t.boolean :required
#   t.boolean :multi_select
#   t.boolean :enabled, default: true
#   t.integer :position, default: 0
#
#   t.references :created_by
#   t.references :updated_by
#
#   t.timestamps
# end
#
# add_index :product_option_applicabilities, [:optioned_record_type, :optioned_record_id], :name => 'prod_opt_appl_optioned_record_idx'
# add_index :product_option_applicabilities, :product_option_type_id, :name => 'prod_opt_appl_opt_type_idx'
# add_index :product_option_applicabilities, :position, name: 'product_opts_applicability_pos_idx'

class ProductOptionApplicability < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :optioned_record, polymorphic: true
  belongs_to :product_option_type
  has_many :selected_product_options, dependent: :destroy

  default_scope { where(enabled: true) }
  default_scope { order('position asc') }

  def to_data_hash(options={})
  	data = to_hash(only: [:id, :description, :required, :multi_select])

  	data[:product_option_type] = self.product_option_type.to_data_hash(options)

  	data
  end
  alias :to_mobile_data_hash :to_data_hash
  
end
