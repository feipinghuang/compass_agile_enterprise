class TaskPartyRole < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :task
  belongs_to :party
  belongs_to :task_party_role_type

end
