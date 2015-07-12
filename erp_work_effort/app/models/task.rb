class Task < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  has_many :task_party_roles, :dependent => :destroy

  has_tracked_status

  def to_label
    description
  end

end
