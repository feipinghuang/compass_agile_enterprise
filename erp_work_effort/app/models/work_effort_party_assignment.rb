## Work Effort Assignments - what is necessary to complete this work effort

## work_effort_party_assignments
## this is straight entity_party_role pattern with from and thru dates, but we are keeping
## the DMRB name for this entity.
class WorkEffortPartyAssignment < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to  :work_effort
  belongs_to  :party
  belongs_to  :role_type

  def to_data_hash
    to_hash(only: [{:id => 'server_id'}, :work_effort_id, :party_id], units: 100)
  end

end