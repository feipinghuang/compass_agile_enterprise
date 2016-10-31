# create_table :applications do |t|
#   t.column :description, :string
#   t.column :icon, :string
#   t.column :internal_identifier, :string
#   t.column :type, :string
#   t.column :can_delete, :boolean, :default => true
#
#   t.timestamps
# end
#
# add_index :applications, :internal_identifier, :name => 'applications_internal_identifier_idx'

class Application < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_user_preferences
  has_file_assets
  has_party_roles

  has_and_belongs_to_many :users

  validates_uniqueness_of :internal_identifier, :scope => :type, :case_sensitive => false

  class << self
    def iid(internal_identifier)
      find_by_internal_identifier(internal_identifier)
    end

    def generate_unique_iid(name)
      iid = name.to_iid

      iid_exists = true
      iid_test = iid
      iid_counter = 1
      while iid_exists
        if Application.where(internal_identifier: iid_test).first
          iid_test = "#{iid}_#{iid_counter}"
          iid_counter += 1
        else
          iid_exists = false
          iid = iid_test
        end
      end

      iid
    end

    def apps
      where('type is null')
    end

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
        statement = joins("inner join entity_party_roles as #{table_alias} on #{table_alias}.entity_record_id = applications.id
                           and #{table_alias}.entity_record_type = 'Application'")
        .where("#{table_alias}.party_id" => party).uniq
      else
        statement = joins("inner join entity_party_roles as \"#{table_alias}\" on \"#{table_alias}\".entity_record_id = applications.id
                         and \"#{table_alias}\".entity_record_type = 'Application'")
        .where("#{table_alias}.party_id" => party).uniq
      end

      if options[:role_types]
        statement = statement.where("#{table_alias}.role_type_id" => RoleType.find_child_role_types(options[:role_types]))
      end

      statement
    end

    def allows_business_modules
      where('allow_business_modules = ?', true)
    end

    def desktop_applications
      where('type = ?', 'DesktopApplication')
    end

    alias tools desktop_applications
  end

  def to_data_hash
    to_hash(only: [:id,
                   :description,
                   :internal_identifier,
                   :icon,
                   :created_at,
                   :updated_at])
  end

end
