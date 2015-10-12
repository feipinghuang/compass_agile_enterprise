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

  belongs_to :work_effort
  belongs_to :party
  belongs_to :role_type

  class << self

    #
    # scoping helpers
    #

    # scope by dba organization
    #
    # @param dba_organization [Party] dba organization to scope by
    #
    # @return [ActiveRecord::Relation]
    def scope_by_dba_organization(dba_organization)
      joins(:work_effort)
          .joins("inner join entity_party_roles on entity_party_roles.entity_record_type = 'WorkEffort' and entity_party_roles.entity_record_id = work_efforts.id")
          .where('entity_party_roles.party_id' => dba_organization)
          .where('entity_party_roles.role_type_id = ?', RoleType.iid('dba_org').id)
    end

    alias scope_by_dba scope_by_dba_organization

    # scope by project
    #
    # @param project [Integer | Project | Array] either a id of Project record, a Project record, an array of Project records
    # or an array of Project ids
    #
    # @return [ActiveRecord::Relation]
    def scope_by_project(project)
      joins(:work_effort).where('work_efforts.project_id' => project)
    end

    # scope by work_effort
    #
    # @param work_effort [Integer | WorkEffort | Array] either a id of WorkEffort record, a WorkEffort record, an array of WorkEffort records
    # or an array of WorkEffort ids
    #
    # @return [ActiveRecord::Relation]
    def scope_by_work_effort(work_effort)
      where('work_effort_id' => work_effort)
    end
  end

  # converts this record a hash data representation
  #
  # @return [Hash] data of record
  def to_data_hash
    to_hash(only: [:id, :resource_allocation],
            work_effort: try(:work_effort).try(:to_data_hash),
            party: try(:party).try(:to_data_hash))
  end

end