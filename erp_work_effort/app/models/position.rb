class Position < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :party
  belongs_to :position_type

end
