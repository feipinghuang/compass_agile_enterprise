class AddTaskTypes

  def self.up
    %w{ bug_fix enhancement design business_development system_admin business_admin
    	}.each do |task_type|
      unless TaskType.iid(task_type)
        TaskType.create(
            description: task_type.titleize,
            internal_identifier: task_type
        )
      end
    end
  end

  def self.down
    %w{ bug_fix enhancement design business_development system_admin business_admin
    	}.each do |task_type|
      existing_task_type = TaskType.iid(task_type)
      existing_task_type.destroy if existing_task_type
    end
  end

end
