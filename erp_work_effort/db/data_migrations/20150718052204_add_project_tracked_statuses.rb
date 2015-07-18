class AddProjectTrackedStatuses

  def self.up

    project_statuses = TrackedStatusType.create(internal_identifier: 'project_statuses', description: 'Project Statuses')

    [
        ['active', 'Active'],
        ['hold', 'Hold'],
        ['completed', 'Completed'],
        ['canceled', 'Cancelled']
    ].each do |data|
      status = TrackedStatusType.create(internal_identifier: data[0], description: data[1])
      status.move_to_child_of(project_statuses)
    end

  end

  def self.down
    project_statuses = TrackedStatusType.find_by_internal_identifier('project_statuses')
    project_statuses.destroy
  end

end
