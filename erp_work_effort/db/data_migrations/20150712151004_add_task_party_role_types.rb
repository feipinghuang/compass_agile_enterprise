# This migration comes from erp_work_effort (originally 20150712151004)
class AddTaskPartyRoleTypes

  def self.up
    task_role_type = RoleType.find_or_create("task_assignee", "Task Assignee", RoleType.iid("application_composer"))
    RoleType.find_or_create("developer", "Developer", task_role_type)
    RoleType.find_or_create("business_analyst", "Business Analyst", task_role_type)
    RoleType.find_or_create("quality_assurance", "Quality Assurance", task_role_type)
    RoleType.find_or_create("project_manager", "Project Manager", task_role_type)
  end

  def self.down
    task_role_type = RoleType.find_or_create("task_assignee", "Task Assignee", RoleType.iid("application_composer"))
    task_role_type.destroy
  end

end

