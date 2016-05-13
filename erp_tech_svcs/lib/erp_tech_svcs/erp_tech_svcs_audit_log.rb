module ErpTechSvcs
  class ErpTechSvcsAuditLog
    class << self

      #log when a user logs out
      def successful_logout(user)

        if user.is_a? Integer
          user = User.find(user)
        end

        AuditLog.create(
            :party_id => user.party.id,
            :event_record => user,
            :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','successful_logout'),
            :description => "User #{user.username} successfully logged out."
        )
      end

      #log when a user logs out
      def successful_login(user)
        AuditLog.create(
            :party_id => user.party.id,
            :event_record => user,
            :audit_log_type => AuditLogType.find_by_type_and_subtype_iid('application','successful_login'),
            :description => "User #{user.username} successfully logged in."
        )
      end

    end #class << self
  end #ErpTechSvcsAuditLog
end #ErpTechSvcs