class Project < ActiveRecord::Base

  attr_protected :created_at, :updated_at

  has_many :work_efforts, :dependent => :destroy
  has_and_belongs_to_many :biz_txn_acct_roots

  tracks_created_by_updated_by
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
      scope_by_party(dba_organization, {role_types: [RoleType.iid('dba_org')]})
    end

    alias scope_by_dba scope_by_dba_organization

    # scope by party
    #
    # @param party [Integer | Party | Array] either a id of Party record, a Party record, an array of Party records
    # or an array of Party ids
    # @param options [Hash] options to apply to this scope
    # @option options [Array] :role_types role types to include in the scope
    #
    # @return [ActiveRecord::Relation]
    def scope_by_party(party, options={})
      table_alias = String.random
      if ActiveRecord::Base.connection.adapter_name == "Mysql2"
        statement = joins("inner join entity_party_roles as #{table_alias} on #{table_alias}.entity_record_id = projects.id
                           and #{table_alias}.entity_record_type = 'Project'")
                        .where("#{table_alias}.party_id" => party).uniq
      else
        statement = joins("inner join entity_party_roles as \"#{table_alias}\" on \"#{table_alias}\".entity_record_id = projects.id
                           and \"#{table_alias}\".entity_record_type = 'Project'")
                        .where("#{table_alias}.party_id" => party).uniq
      end

      if options[:role_types]
        statement = statement.where("#{table_alias}.role_type_id" => RoleType.find_child_role_types(options[:role_types]))
      end

      statement
    end
  end

  def to_label
    description
  end

  def to_data_hash
    to_hash(only: [:id, :description, :created_at, :updated_at])
  end

end
