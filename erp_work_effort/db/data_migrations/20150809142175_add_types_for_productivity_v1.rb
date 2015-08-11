class AddTypesForProductivityV1
  
  def self.up

    base_productivity_role_type =  RoleType.new
    base_productivity_role_type.internal_identifier= 'productivity_root_role'
    base_productivity_role_type.description= "Productivity Roles"
    base_productivity_role_type.save

    base_assignee_role_type = RoleType.new
    base_assignee_role_type.internal_identifier='work_effort_assignee'
    base_assignee_role_type.description='Assignee'
    base_assignee_role_type.save

    base_assignee_role_type.move_to_child_of(base_productivity_role_type)

  end
  
  def self.down

    base_productivity_role_type = RoleType.iid('productivity_root_role')
    base_assignee_role_type  = RoleType.iid('work_effort_assignee')

    base_productivity_role_type.destroy if base_productivity_role_type

  end

end
