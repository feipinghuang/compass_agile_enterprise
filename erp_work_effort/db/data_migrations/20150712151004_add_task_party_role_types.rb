class AddTaskPartyRoleTypes

  def self.up
    if TaskPartyRoleType.find_by_internal_identifier('assignee').nil?
      TaskPartyRoleType.create(description: 'Assignee', internal_identifier: 'assignee')
    end
  end

  def self.down
    unless TaskPartyRoleType.find_by_internal_identifier('assignee').nil?
      TaskPartyRoleType.find_by_internal_identifier('assignee').destroy
    end
  end

end

