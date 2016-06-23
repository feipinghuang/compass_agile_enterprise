#  create_table :audit_log_types do |t|
#    t.string :description
#    t.string :error_code
#    t.string :comments
#    t.string :internal_identifier
#    t.string :external_identifier
#    t.string :external_id_source
#
#    # awesome nested set columns
#    t.integer :parent_id
#    t.integer :lft
#    t.integer :rgt
#
#    t.timestamps
#  end
#
#  add_index :audit_log_types, :internal_identifier, :name => 'audit_log_types_internal_identifier_idx'
#  add_index :audit_log_types, :parent_id, :name => 'audit_log_types_parent_id_idx'

class AuditLogType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many :audit_logs
  belongs_to_erp_type :parent, :class_name => "AuditLogType"

  # find by type Internal Identifier and subtype Internal Identifier
  def self.find_by_type_and_subtype_iid(txn_type, txn_subtype)
    result = nil
    txn_type_recs = find_all_by_internal_identifier(txn_type.strip)
    txn_type_recs.each do |txn_type_rec|
      txn_subtype_rec = find_by_parent_id_and_internal_identifier(txn_type_rec.id, txn_subtype.strip)
      result = txn_subtype_rec
      unless txn_subtype_rec.nil?
        result = txn_subtype_rec
        break
      end
    end unless txn_type_recs.blank?

    result
  end

end
