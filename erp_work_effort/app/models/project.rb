class Project < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  has_many :work_efforts, :dependent => :destroy

  has_tracked_status
  has_party_roles

  def to_label
    description
  end

  def to_data_hash
    to_hash(only: [:id, :description, :created_at, :updated_at])
  end

end
