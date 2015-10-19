class AddReportRoleType
  
  def self.up
    RoleType.create(
      description: 'Report',
      internal_identifier: 'report'
    ) unless RoleType.iid('report')
  end

  def self.down
    report_role = RoleType.iid('report')
    report_role.destroy if report_role
  end

end
