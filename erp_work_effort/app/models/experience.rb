class Experience < ActiveRecord::Base

  tracks_created_by_updated_by

  belongs_to :party
  belongs_to :experience_type

  attr_protected :created_at, :updated_at
  attr_accessible :description

end
