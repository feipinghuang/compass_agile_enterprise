class Resume < ActiveRecord::Base

	attr_protected :created_at,:updated_at

  belongs_to :party

  has_file_assets

  has_tracked_status

end