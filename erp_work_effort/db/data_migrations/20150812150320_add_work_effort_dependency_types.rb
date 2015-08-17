  class AddWorkEffortDependencyTypes

  def self.up
    dependency = WorkEffortAssociationType.create(description: 'Dependency', internal_identifier: 'dependency')

    start_to_start = WorkEffortAssociationType.create(description: 'StartToStart',
                                                     internal_identifier: 'start_to_start',
                                                     external_identifier: 0)

    start_to_start.move_to_child_of(dependency)

    start_to_end = WorkEffortAssociationType.create(description: 'StartToEnd',
                                                     internal_identifier: 'start_to_end',
                                                     external_identifier: 1)

    start_to_end.move_to_child_of(dependency)

    end_to_start = WorkEffortAssociationType.create(description: 'EndToStart',
                                                     internal_identifier: 'end_to_start',
                                                     external_identifier: 2)

    end_to_start.move_to_child_of(dependency)

    end_to_end = WorkEffortAssociationType.create(description: 'EndToEnd',
                                                     internal_identifier: 'end_to_end',
                                                     external_identifier: 3)

    end_to_end.move_to_child_of(dependency)
  end

  def self.down
    WorkEffortAssociationType.iid('dependency').destroy
  end

end
