## Work effort associations store precedence, concurrence. They can also store
## task breakdowns, but there is a more efficient nested-set data structure directly on the work_effort
## for this purpose, since it is common to reconstruct large work breakdown structures
## with important read performance requirements

class WorkEffortAssociation < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :work_effort_association_type

  belongs_to :work_effort_from, :class_name => "WorkEffort", :foreign_key => "work_effort_id_from"
  belongs_to :work_effort_to, :class_name => "WorkEffort", :foreign_key => "work_effort_id_to"
  belongs_to :from_role, :class_name => "RoleType", :foreign_key => "role_type_id_from"
  belongs_to :to_role, :class_name => "RoleType", :foreign_key => "role_type_id_to"

  def to_data_hash
    to_hash({
                only: [{id: :server_id}, :work_effort_id_from, :work_effort_id_to],
                work_effort_association_type_id: work_effort_association_type.id,
                work_effort_association_type_external_id: work_effort_association_type.external_identifier
            })
  end

end
