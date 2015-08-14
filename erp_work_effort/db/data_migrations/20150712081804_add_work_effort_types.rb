class AddWorkEffortTypes

  def self.up
    %w{ bug_fix enhancement design business_development system_admin business_admin
    	}.each do |type|
      unless WorkEffortType.iid(type)
        WorkEffortType.create(
            description: type.titleize,
            internal_identifier: type
        )
      end
    end
  end

  def self.down
    %w{ bug_fix enhancement design business_development system_admin business_admin
    	}.each do |type|
      existing_type = WorkEffortType.iid(type)
      existing_type.destroy if existing_type
    end
  end

end
