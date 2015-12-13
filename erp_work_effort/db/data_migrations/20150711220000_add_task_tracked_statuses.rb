class AddTaskTrackedStatuses

  def self.up

    task_statuses = TrackedStatusType.create(internal_identifier: 'task_statuses', description: 'Task Statuses')

    [
        ['task_status_not_started', 'Not Started'],
        ['task_status_in_progress', 'In Progress'],
        ['task_status_completed', 'Completed'],
        ['task_status_hold', 'Hold'],
        ['task_status_canceled', 'Cancelled']
    ].each do |data|
      status = TrackedStatusType.create(internal_identifier: data[0], description: data[1])
      status.move_to_child_of(task_statuses)
    end

  end

  def self.down
    task_statuses = TrackedStatusType.find_by_internal_identifier('task_statuses')
    task_statuses.destroy
  end

end
