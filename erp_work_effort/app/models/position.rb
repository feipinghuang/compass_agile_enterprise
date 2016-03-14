class Position < ActiveRecord::Base

  tracks_created_by_updated_by

  belongs_to :party
  belongs_to :position_type

end
