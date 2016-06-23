class BizTxnAcctPtyRtype < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :biz_txn_acct_party_roles

end
