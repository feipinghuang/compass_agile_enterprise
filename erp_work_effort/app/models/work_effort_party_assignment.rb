## Work Effort Assignments - what is necessary to complete this work effort

## work_effort_party_assignments
## this is straight entity_party_role pattern with from and thru dates, but we are keeping
## the DMRB name for this entity.

# creat e_table :work_effort_party_assignments do |t|
#   foreign key references
#   t.references :work_effort
#   t.references :role_type
#   t.references :party
#
#   t.datetime :assigned_from
#   t.datetime :assigned_thru
#
#   t.text :comments
#
#   t.integer :resource_allocation
#
#   t.timestamps
#   end
#
#   add_index :work_effort_party_assignments, :assigned_from
#   add_index :work_effort_party_assignments, :assigned_thru
#   add_index :work_effort_party_assignments, :work_effort_id
#   add_index :work_effort_party_assignments, :party_id

class WorkEffortPartyAssignment < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to  :work_effort
  belongs_to  :party
  belongs_to  :role_type

  def to_data_hash
    to_hash(only: [{:id => 'server_id'}, :work_effort_id, :party_id, :resource_allocation])
  end

end