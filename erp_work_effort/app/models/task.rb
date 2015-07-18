class Task < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  belongs_to :project

  has_tracked_status
  has_party_roles

  def to_label
    description
  end

end
