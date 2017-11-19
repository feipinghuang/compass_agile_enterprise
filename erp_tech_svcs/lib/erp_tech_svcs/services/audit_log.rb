module ErpTechSvcs
  module Services
    class AuditLog

      def initialize(user, tenant=nil)
        if user.is_a? Integer
          @user = User.find(user)
        else
          @user = user
        end

        @tenant = tenant || user.party.dba_organization
      end

      #Log when a user logs out
      def successful_login
        ::AuditLog.create!(
          party_id: @user.party.id,
          event_record: @user,
          audit_log_type: AuditLogType.find_by_type_and_subtype_iid('application','successful_login'),
          description: "User #{@user.username} successfully logged in.",
          tenant_id: @tenant.id
        )
      end

      #Log when a user logs out
      def successful_logout
        ::AuditLog.create!(
          party_id: @user.party.id,
          event_record: @user,
          audit_log_type: AuditLogType.find_by_type_and_subtype_iid('application','successful_logout'),
          description: "User #{@user.username} successfully logged out.",
          tenant_id: @tenant.id
        )
      end

      def log_create(record, description=nil)
        description = description || "#{record.class.name} created"

        audit_log_type = ::AuditLogType.find_or_create('audit_log_type_create', 'Log Create')

        audit_log = ::AuditLog.create!(
          party: @user ? @user.party : nil,
          event_record: record,
          audit_log_type: audit_log_type,
          description: description,
          tenant_id: @tenant.id
        )

        audit_log_item = ::AuditLogItem.new

        audit_log_item.audit_log = audit_log
        audit_log_item.description = 'Record ID'
        audit_log_item.audit_log_item_value = record.id

        audit_log_item.save!

        audit_log
      end

      def log_update(record, changes, description=nil)
        description = description || "#{record.class.name} updated"

        audit_log_type = ::AuditLogType.find_or_create('audit_log_type_update', 'Log Update')

        audit_log = ::AuditLog.create!(
          party: @user ? @user.party : nil,
          event_record: record,
          audit_log_type: audit_log_type,
          description: description,
          tenant_id: @tenant.id
        )

        changes.each do |change|
          audit_log_item = ::AuditLogItem.new

          audit_log_item.audit_log = audit_log
          audit_log_item.description = change[:description]
          audit_log_item.audit_log_item_value = change[:new_value]
          audit_log_item.audit_log_item_old_value = change[:old_value]

          audit_log_item.save!
        end

        audit_log
      end

      def log_delete(record, description=nil)
        description = description || "#{record.class.name} #{record.id} deleted"

        audit_log_type = ::AuditLogType.find_or_create('audit_log_type_delete', 'Delete')

        audit_log = ::AuditLog.create!(
          party: @user ? @user.party : nil,
          audit_log_type: audit_log_type,
          description: description,
          tenant_id: @tenant.id
        )

        audit_log_item = ::AuditLogItem.new

        audit_log_item.audit_log = audit_log
        audit_log_item.description = 'Record ID'
        audit_log_item.audit_log_item_value = record.id

        audit_log_item.save!

        audit_log
      end

    end # AuditLog
  end # Services
end # ErpTechSvcs
