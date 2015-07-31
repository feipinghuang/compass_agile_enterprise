# This migration comes from erp_work_effort (originally 20150718054404)
class AddProjectPartyRoleTypes

  def self.up
    project_role_type = RoleType.find_or_create("project_assignee", "Project Assignee", RoleType.iid("application_composer"))
  end

  def self.down
    project_role_type = RoleType.find_or_create("project_assignee", "Project", RoleType.iid("application_composer"))
    project_role_type.destroy
  end

end

