class AddTaskPartyRoleTypes

  def self.up
    task_role_type = RoleType.find_or_create("task", "Task", RoleType.iid("application_composer"))
    RoleType.find_or_create("assignee", "Assignee", task_role_type)
    RoleType.find_or_create("developer", "Developer", task_role_type)
    RoleType.find_or_create("business_analyst", "Business Analyst", task_role_type)
    RoleType.find_or_create("quality_assurance", "Quality Assurance", task_role_type)
    RoleType.find_or_create("project_manager", "Project Manager", task_role_type)
  end

  def self.down
    task_role_type = RoleType.find_or_create("task", "Task", RoleType.iid("application_composer"))
    task_role_type.destroy
  end

end

