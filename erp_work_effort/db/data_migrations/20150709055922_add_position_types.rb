class AddPositionTypes

  def self.up
    %w{executive_management software_developer infrastructure_engineer project_manager
    	 program_manager network_operations_manager network_engineer
    	 quality_assurance_teste uncategorized
    	}.each do |position_type|
  		unless PositionType.iid(position_type)
  			PositionType.create(
	        description: position_type.titleize,
	        internal_identifier: position_type
		    )
  		end
    end
  end

  def self.down
   %w{executive_management software_developer infrastructure_engineer project_manager
    	 program_manager network_operations_manager network_engineer
    	 quality_assurance_teste uncategorized
    	}.each do |position_type|
  		existing_position_type = PositionType.iid(position_type)
  		existing_position_type.destroy if existing_position_type
    end
  end

end
