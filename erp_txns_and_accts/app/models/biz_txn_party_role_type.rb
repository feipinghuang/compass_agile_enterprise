class BizTxnPartyRoleType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  def self.iid(internal_identifier)
    find_by_internal_identifier(internal_identifier)
  end

end
