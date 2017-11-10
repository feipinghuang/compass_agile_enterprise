class PartyAchievement < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_json :custom_fields

  belongs_to :party

end
