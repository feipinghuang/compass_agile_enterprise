class AddProjectPartyRoleTypes

  def self.up

    project_role_type = RoleType.where("internal_identifier = 'project' and parent_id is null").first
    if project_role_type.nil?
      project_role_type = RoleType.create(description: 'Project', internal_identifier: 'project')
    end

    if  RoleType.where("internal_identifier = 'assignee' and parent_id = ?", project_role_type.id).first.nil?
      assignee_role_type = RoleType.create(description: 'Assignee', internal_identifier: 'assignee')
      assignee_role_type.move_to_child_of(project_role_type)
    end
  end

  def self.down
    project_role_type = RoleType.where("internal_identifier = 'project' and parent_id is null").first
    unless project_role_type.nil?
      assignee_role_type = RoleType.where("internal_identifier = 'assignee' and parent_id = ?", project_role_type.id).first
      unless assignee_role_type.nil?
        EntityPartyRole.destroy_all("where role_type_id = ?", assignee_role_type.id)
        assignee_role_type.destroy
      end
    end
  end

end

