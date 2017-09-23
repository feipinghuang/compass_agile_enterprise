# create_table :agreement_types do |t|
# 	t.column  :parent_id, :integer
# 	t.column  :lft,       :integer
# 	t.column  :rgt,       :integer
#
#   #custom columns go here   
# 	t.column  :description,         :string
# 	t.column  :comments,            :string
#   t.column  :internal_identifier, :string
#   t.column  :external_identifier, :string
#   t.column  :external_id_source, 	:string
#     
# 	t.timestamps
# end
#
# add_index :agreement_types, :parent_id
# add_index :agreement_types, :lft
# add_index :agreement_types, :rgt

class AgreementType < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  
  is_tenantable
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :agreements

  def to_data_hash
  	to_hash(only: [:id, :description, :internal_identifier, :external_identifier, :external_id_source])
  end
end
