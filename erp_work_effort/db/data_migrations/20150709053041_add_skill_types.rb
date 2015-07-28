class AddSkillTypes

  def self.up
    %w{programming project_management program_management business_development
    	 business_analysis infrastructure_engineering network_operations web_design
    	 mobile_design mobile_development quality_assurance uncategorized
    	}.each do |skill_type|
  		unless SkillType.iid(skill_type)
  			SkillType.create(
		        description: skill_type.titleize,
		        internal_identifier: skill_type
		    )
  		end
    end
  end

  def self.down
  	%w{programming project_management program_management business_development
    	 business_analysis infrastructure_engineering network_operations web_design
    	 mobile_design mobile_development quality_assurance uncategorized
    	}.each do |skill_type|
    	existing_skill_type = SkillType.iid(skill_type)
    	existing_skill_type.destroy if existing_skill_type
    end
  end

end
