class Category < ActiveRecord::Base
  acts_as_nested_set

  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  acts_as_erp_type

  attr_protected :created_at, :updated_at

  belongs_to :category_record, :polymorphic => true
  has_many :category_classifications, :dependent => :destroy
  
  def self.iid( internal_identifier_string )
    where("internal_identifier = ?",internal_identifier_string.to_s).first
  end

  def to_data_hash
    {
        server_id: id,
        leaf: children.empty?,
        description: description,
        internal_identifier: internal_identifier,
        created_at: created_at,
        updated_at: updated_at
    }
  end

end
