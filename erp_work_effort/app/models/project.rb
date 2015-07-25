class Project < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  has_many :tasks, :dependent => :destroy

  has_tracked_status
  has_party_roles

  def to_label
    description
  end

end
