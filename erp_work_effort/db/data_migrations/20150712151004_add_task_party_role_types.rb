class AddTaskPartyRoleTypes

  def self.up

    task_role_type = RoleType.where("internal_identifier = 'task' and parent_id is null").first
    if task_role_type.nil?
      task_role_type = RoleType.create(description: 'Task', internal_identifier: 'task')
    end

    if  RoleType.where("internal_identifier = 'assignee' and parent_id = ?", task_role_type.id).first.nil?
      assignee_role_type = RoleType.create(description: 'Assignee', internal_identifier: 'assignee')
      assignee_role_type.move_to_child_of(task_role_type)
    end
  end

  def self.down
    task_role_type = RoleType.where("internal_identifier = 'task' and parent_id is null").first
    unless task_role_type.nil?
      assignee_role_type = RoleType.where("internal_identifier = 'assignee' and parent_id = ?", task_role_type.id).first
      unless assignee_role_type.nil?
        EntityPartyRole.destroy_all("where role_type_id = ?", assignee_role_type.id)
        assignee_role_type.destroy
      end
    end
  end

end

