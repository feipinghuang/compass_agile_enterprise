class AddProjectPartyRoleTypes

  def self.up
    project_role_type = RoleType.find_or_create("project", "Project", RoleType.iid("application_composer"))
    RoleType.find_or_create("assignee", "Assignee", project_role_type)
  end

  def self.down
    project_role_type = RoleType.find_or_create("project", "Project", RoleType.iid("application_composer"))
    project_role_type.destroy
  end

end

