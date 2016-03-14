class PartySkill < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :party
  belongs_to :skill_type
end
