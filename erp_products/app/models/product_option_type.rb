# create_table :product_option_types do |t|
#   t.string :description
#   t.string :internal_identifier
#
#   t.string :selection_type
#
#   t.integer :parent_id
#   t.integer :lft
#   t.integer :rgt

#   t.references :tenant
#
#   t.references :created_by
#   t.references :updated_by
#
#   t.timestamps
# end
#
# add_index :product_option_types, :internal_identifier, :name => 'prod_opt_types_iid_idx'
# add_index :product_option_types, :selection_type, :name => 'prod_opt_types_selection_type_idx'
# add_index :product_option_types, [:parent_id, :lft, :rgt], :name => 'prod_opt_types_nested_idx'
# add_index :product_option_types, :tenant_id, :name => 'prod_opt_types_tenant_id_idx'

class ProductOptionType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by
  is_tenantable
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :product_options, dependent: :destroy
  has_many :product_option_applicabilities, dependent: :destroy

  def to_label
    "#{description} - #{selection_type.capitalize}"
  end

  def to_data_hash(options={})
  	data = to_hash(only: [:id, :description, :internal_identifier, :selection_type], label: to_label)

    if options[:include_options]
      data[:options] = product_options.collect(&:to_data_hash)
    end

    data
  end

  alias :to_mobile_data_hash :to_data_hash

end
