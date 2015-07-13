class AddTaskTrackedStatuses
  
  def self.up

    task_statuses = TrackedStatusType.create(internal_identifier: 'task_statuses', description: 'Task Statuses')

    [
        ['not_started', 'Not Started'],
        ['in_progress', 'In Progress'],
        ['completed', 'Completed'],
        ['hold', 'Hold'],
        ['canceled', 'Cancelled']
    ].each do |data|
      status = TrackedStatusType.create(internal_identifier: data[0], description: data[1])
      status.move_to_child_of(task_statuses)
    end

  end
  
  def self.down
    task_statuses = TrackedStatusType.find
  end

end
