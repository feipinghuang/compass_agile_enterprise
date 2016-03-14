# create_table :audit_log_items do |t|
#   t.references :audit_log
#   t.references :audit_log_item_type
#   t.string :audit_log_item_value
#   t.string :audit_log_item_old_value
#   t.string :description
#
#   t.timestamps
# end
#
# add_index :audit_log_items, :audit_log_id, :name => 'audit_log_items_audit_log_id_idx'
# add_index :audit_log_items, :audit_log_item_type_id, :name => 'audit_log_items_audit_log_item_type_id_idx'

class AuditLogItem < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :audit_log_item_type
  belongs_to :audit_log

  alias :type  :audit_log_item_type

  # convert to hash of data
  #
  def to_data_hash
    data = to_hash(only: [:id,
                          {audit_log_item_value: :new_value},
                          {audit_log_item_old_value: :old_value},
                          :description,
                          :created_at,
                          :updated_at])

    if audit_log_item_type
      data[:audit_log_item_type] = audit_log_item_type.to_data_hash
    end

    data
  end
end
