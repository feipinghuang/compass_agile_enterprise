class PartyAchievement < ActiveRecord::Base
  # attr_accessible :title, :body

  is_json :custom_fields

  belongs_to :party

end
