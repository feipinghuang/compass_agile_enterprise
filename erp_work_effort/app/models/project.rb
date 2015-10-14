class Project < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  has_many :work_efforts, :dependent => :destroy

  has_tracked_status
  has_party_roles

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
      joins("inner join entity_party_roles on entity_party_roles.entity_record_type = 'Project' and entity_party_roles.entity_record_id = projects.id")
          .where('entity_party_roles.party_id' => dba_organization)
          .where('entity_party_roles.role_type_id = ?', RoleType.iid('dba_org').id)
    end

    alias scope_by_dba scope_by_dba_organization
  end

  def to_label
    description
  end

  def to_data_hash
    to_hash(only: [:id, :description, :created_at, :updated_at])
  end

end
