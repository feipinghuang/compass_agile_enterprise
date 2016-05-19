class StaffingPosition < ActiveRecord::Base
  attr_accessible :description, :internal_identifier, :shift

  tracks_created_by_updated_by

  #must be after is_json
  acts_as_product_type

end
