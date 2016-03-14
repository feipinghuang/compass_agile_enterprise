# create_table :audit_logs do |t|
#   t.string :application
#   t.string :description
#   t.integer :party_id
#   t.text :additional_info
#   t.references :audit_log_type
#
#   #polymorphic columns
#   t.references :event_record, :polymorphic => true
#
#   t.timestamps
# end
# add_index :audit_logs, :party_id
# add_index :audit_logs, [:event_record_id, :event_record_type], :name => 'event_record_index'
# add_index :audit_logs, :audit_log_type_id, :name => 'audit_logs_audit_log_type_id_idx'

class AuditLog < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_tenantable

  validates :party_id, :presence => {:message => 'cannot be blank'}
  validates :description, :presence => {:message => 'cannot be blank'}
  validates :audit_log_type, :presence => {:message => 'cannot be blank'}

  belongs_to :audit_log_type
  belongs_to :party
  belongs_to :event_record, :polymorphic => true
  has_many :audit_log_items, :dependent => :destroy

  alias :items :audit_log_items
  alias :type :audit_log_type

  class << self

    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      audit_log_tbl = self.arel_table

      unless statement
        statement = self
      end

      # filter by tenant
      unless filters[:tenant].blank?
        statement = statement.by_tenant(filters[:tenant])
      end

      # filter by logged by
      unless filters[:logged_by].blank?
        statement = statement.where(party_id: filters[:logged_by].split(','))
      end

      # filter by start_at
      unless filters[:start_date].blank?
        statement = statement.where(audit_log_tbl[:created_at].gteq(Date.parse(filters[:start_date])))
      end

      # filter by end_at
      unless filters[:end_date].blank?
        statement = statement.where(audit_log_tbl[:created_at].lteq(Date.parse(filters[:end_date])))
      end

      statement
    end

    def custom_application_log_message(party, msg)
      self.create(
          :party_id => party.id,
          :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application', 'custom_message'),
          :description => "#{party.description}: #{msg}"
      )
    end

    def party_logout(party)
      self.create(
          :party_id => party.id,
          :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application', 'successful_logout'),
          :description => "#{party.description} has logged out"
      )
    end

    def party_login(party)
      self.create(
          :party_id => party.id,
          :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application', 'successful_login'),
          :description => "#{party.description} has logged in"
      )
    end

    def party_access(party, url)
      self.create(
          :party_id => party.id,
          :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application', 'accessed_area'),
          :description => "#{party.description} has accessed area #{url}"
      )
    end

    def party_failed_access(party, url)
      self.create(
          :party_id => party.id,
          :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application', 'accessed_area'),
          :description => "#{party.description} has tried to access a restricted area #{url}"
      )
    end

    def party_session_timeout(party)
      self.create(
          :party_id => party.id,
          :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application', 'session_timeout'),
          :description => "#{party.description} session has expired"
      )
    end
  end

  def get_item_by_item_type_internal_identifier(item_type_internal_identifier)
    self.items.includes(:audit_log_item_type)
        .where(:audit_log_item_types => {:internal_identifier => item_type_internal_identifier}).first
  end

  # convert to hash of data
  #
  def to_data_hash
    data = to_hash(only: [:id, :application, :additional_info, :description, :created_at])

    data[:party] = party.to_data_hash

    if event_record.respond_to?(:to_data_hash)
      data[:event_record] = event_record.to_data_hash
    else
      data[:event_record] = {id: event_record.id, type: event_record.class.name}
    end

    if type
      data[:audit_log_type] = audit_log_type.to_data_hash
    end

    data
  end

  # allow items to be looked up by method calls
  def respond_to?(m, include_private_methods = false)
    (super ? true : get_item_by_item_type_internal_identifier(m.to_s)) rescue super
  end

  # allow items to be looked up by method calls
  def method_missing(m, *args, &block)
    if self.respond_to?(m)
      item = get_item_by_item_type_internal_identifier(m.to_s)
      (item.nil?) ? super : (return item.audit_log_item_value)
    else
      super
    end
  end

end
