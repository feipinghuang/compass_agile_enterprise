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
        if Application.where(:internal_identifier => iid_test).first
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

    def associated_to_party(party, role_type)
      entity_party_roles_tbl = EntityPartyRole.arel_table

      joins("left outer join entity_party_roles on entity_party_roles.entity_record_type = 'Application'
             and entity_party_roles.entity_record_id = applications.id")
          .where(entity_party_roles_tbl[:party_id].eq(party.id).and(entity_party_roles_tbl[:role_type_id].eq(role_type.id)))
    end

    def allows_business_modules
      where('allow_business_modules = ?', true)
    end

    def desktop_applications
      where('type = ?', 'DesktopApplication')
    end
  end

  def to_data_hash
    to_hash(only: [:id,
                   :description,
                   :internal_identifier,
                   :created_at,
                   :updated_at])
  end

end
