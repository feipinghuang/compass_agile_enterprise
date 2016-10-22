class BaseErpServices < ActiveRecord::Migration
  def self.up

    unless table_exists?(:compass_ae_instances)
      create_table :compass_ae_instances do |t|
        t.string :description
        t.string :internal_identifier
        t.decimal :version, :precision => 8, :scale => 3
        t.string :type
        t.string :schema, :default => 'public'
        t.integer :parent_id
        t.string :guid

        t.timestamps
      end

      add_index :compass_ae_instances, :internal_identifier, :name => "iid_idx"
      add_index :compass_ae_instances, :schema, :name => "schema_idx"
      add_index :compass_ae_instances, :type, :name => "type_idx"
      add_index :compass_ae_instances, :parent_id, :name => "parent_id_idx"
      add_index :compass_ae_instances, :guid, :name => "guid_idx"
    end

    unless table_exists?(:compass_ae_instance_party_roles)
      create_table :compass_ae_instance_party_roles do |t|
        t.string :description
        t.integer :compass_ae_instance_id
        t.integer :party_id
        t.integer :role_type_id

        t.timestamps
      end

      add_index :compass_ae_instance_party_roles, :compass_ae_instance_id, :name => "compass_ae_instance_id_idx"
      add_index :compass_ae_instance_party_roles, :party_id, :name => "party_id_idx"
      add_index :compass_ae_instance_party_roles, :role_type_id, :name => "role_type_id_idx"
    end

    # Create parties table
    unless table_exists?(:parties)
      create_table :parties do |t|
        t.column :description, :string
        t.column :business_party_id, :integer
        t.column :business_party_type, :string
        t.column :list_view_image_id, :integer

        #This field is here to provide a direct way to map CompassAE
        #business parties to unified idenfiers in organizations if they
        #have been implemented in an enterprise.
        t.column :enterprise_identifier, :string
        t.timestamps
      end
      add_index :parties, [:business_party_id, :business_party_type], :name => "besi_1"
    end

    # Create party_roles table
    unless table_exists?(:party_roles)
      create_table :party_roles do |t|
        #this column holds the class name of the
        #subtype of party-to-role_type relatsionship
        t.column :type, :string
        #xref between party and role_type
        t.column :party_id, :integer
        t.column :role_type_id, :integer
        t.timestamps
      end
      add_index :party_roles, :party_id
      add_index :party_roles, :role_type_id
    end


    # Create role_types table
    unless table_exists?(:role_types)
      create_table :role_types do |t|
        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here
        t.column :description, :string
        t.column :comments, :string
        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end

      add_index :role_types, :internal_identifier, :name => "role_types_iid_idx"
      add_index :role_types, :parent_id, :name => "role_types_parent_id_idx"
      add_index :role_types, :lft, :name => "role_types_lft_idx"
      add_index :role_types, :rgt, :name => "role_types_rgt_idx"
    end

    # Create relationship_types table
    unless table_exists?(:relationship_types)
      create_table :relationship_types do |t|
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here
        t.column :valid_from_role_type_id, :integer
        t.column :valid_to_role_type_id, :integer
        t.column :name, :string
        t.column :description, :string

        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end

      add_index :relationship_types, :valid_from_role_type_id
      add_index :relationship_types, :valid_to_role_type_id
      add_index :relationship_types, :parent_id, :name => 'relationship_types_parent_id_idx'
      add_index :relationship_types, :internal_identifier, :name => 'relationship_types_internal_identifier_idx'
    end

    # Create party_relationships table
    unless table_exists?(:party_relationships)
      create_table :party_relationships do |t|
        t.column :description, :string
        t.column :party_id_from, :integer
        t.column :party_id_to, :integer
        t.column :role_type_id_from, :integer
        t.column :role_type_id_to, :integer
        t.column :status_type_id, :integer
        t.column :priority_type_id, :integer
        t.column :relationship_type_id, :integer
        t.column :from_date, :date
        t.column :thru_date, :date
        t.column :external_identifier, :string
        t.column :external_id_source, :string
        t.timestamps
      end
      add_index :party_relationships, :status_type_id
      add_index :party_relationships, :priority_type_id
      add_index :party_relationships, :relationship_type_id
    end

    # Create organizations table
    unless table_exists?(:organizations)
      create_table :organizations do |t|
        t.column :description, :string
        t.column :tax_id_number, :string
        t.timestamps
      end
    end

    # Create individuals table
    unless table_exists?(:individuals)
      create_table :individuals do |t|
        t.column :party_id, :integer
        t.column :current_last_name, :string
        t.column :current_first_name, :string
        t.column :current_middle_name, :string
        t.column :current_personal_title, :string
        t.column :current_suffix, :string
        t.column :current_nickname, :string
        t.column :gender, :string, :limit => 1
        t.column :birth_date, :date
        t.column :height, :decimal, :precision => 5, :scale => 2
        t.column :weight, :integer
        t.column :mothers_maiden_name, :string
        t.column :marital_status, :string, :limit => 1
        t.column :social_security_number, :string
        t.column :current_passport_number, :integer

        t.column :current_passport_expire_date, :date
        t.column :total_years_work_experience, :integer
        t.column :comments, :string
        t.column :encrypted_ssn, :string
        t.column :temp_ssn, :string
        t.column :salt, :string
        t.column :ssn_last_four, :string
        t.timestamps
      end
      add_index :individuals, :party_id
    end

    # Create contacts table
    unless table_exists?(:contacts)
      create_table :contacts do |t|
        t.column :party_id, :integer
        t.column :contact_mechanism_id, :integer
        t.column :contact_mechanism_type, :string
        t.column :is_primary, :boolean

        t.column :external_identifier, :string
        t.column :external_id_source, :string

        t.timestamps
      end
      add_index :contacts, :party_id
      add_index :contacts, :is_primary
      add_index :contacts, [:contact_mechanism_id, :contact_mechanism_type], :name => "besi_2"
    end

    # Create contact_types
    unless table_exists?(:contact_types)
      create_table :contact_types do |t|
        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here

        t.column :description, :string
        t.column :comments, :string

        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string

        t.timestamps
      end
      add_index :contact_types, :parent_id
      add_index :contact_types, :lft
      add_index :contact_types, :rgt
      add_index :contact_types, :internal_identifier, :name => 'contact_types_internal_identifier_idx'
    end

    # Create contact_purposes
    unless table_exists?(:contact_purposes)
      create_table :contact_purposes do |t|

        t.column :parent_id, :integer
        t.column :lft, :integer
        t.column :rgt, :integer

        #custom columns go here

        t.column :description, :string
        t.column :comments, :string

        t.column :internal_identifier, :string
        t.column :external_identifier, :string
        t.column :external_id_source, :string

        t.timestamps
      end
      add_index :contact_purposes, :parent_id

    end

    unless table_exists?(:contact_purposes_contacts)
      create_table :contact_purposes_contacts, {:id => false} do |t|
        t.column :contact_id, :integer
        t.column :contact_purpose_id, :integer
      end

      add_index :contact_purposes_contacts, [:contact_id, :contact_purpose_id], :name => "contact_purposes_contacts_index"
      add_index :contact_purposes, :internal_identifier, :name => 'contact_purposes_internal_identifier_idx'
    end

    # Create postal_addresses (a contact_mechanism)
    unless table_exists?(:postal_addresses)
      create_table :postal_addresses do |t|
        t.column :address_line_1, :string
        t.column :address_line_2, :string
        t.column :city, :string
        t.column :state, :string
        t.column :zip, :string
        t.column :country, :string
        t.column :description, :string
        t.column :geo_country_id, :integer
        t.column :geo_zone_id, :integer
        t.column :latitude, :decimal, :precision => 12, :scale => 8
        t.column :longitude, :decimal, :precision => 12, :scale => 8
        t.timestamps
      end
      add_index :postal_addresses, :geo_country_id
      add_index :postal_addresses, :geo_zone_id
    end

    # Create email_addresses (a contact_mechanism)
    unless table_exists?(:email_addresses)
      create_table :email_addresses do |t|
        t.column :email_address, :string
        t.column :description, :string

        t.timestamps
      end
    end

    # Create phone_numbers table (A contact_mechanism)
    unless table_exists?(:phone_numbers)
      create_table :phone_numbers do |t|
        t.column :phone_number, :string
        t.column :description, :string

        t.timestamps
      end
    end

    unless table_exists?(:money)
      create_table :money do |t|
        t.string :description
        t.decimal :amount, :precision => 8, :scale => 2
        t.references :currency
        t.timestamps
      end
      add_index :money, :currency_id
    end

    unless table_exists?(:currencies)
      create_table :currencies do |t|
        t.string :name
        t.string :definition
        t.string :internal_identifier # aka alphabetic_code
        t.string :numeric_code
        t.string :major_unit_symbol
        t.string :minor_unit_symbol
        t.string :ratio_of_minor_unit_to_major_unit
        t.string :postfix_label
        t.datetime :introduction_date
        t.datetime :expiration_date
        t.timestamps
      end
      add_index :currencies, :internal_identifier
    end

    ## categories
    unless table_exists?(:categories)
      create_table :categories do |t|
        t.string :description
        t.string :external_identifier
        t.datetime :from_date
        t.datetime :to_date
        t.string :internal_identifier

        # polymorphic assns
        t.integer :category_record_id
        t.string :category_record_type

        # nested set cols
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end
      add_index :categories, [:category_record_id, :category_record_type], :name => "category_polymorphic"
      add_index :categories, :internal_identifier, :name => 'categories_internal_identifier_idx'
      add_index :categories, :parent_id, :name => 'categories_parent_id_idx'
      add_index :categories, :lft, :name => 'categories_lft_idx'
      add_index :categories, :rgt, :name => 'categories_rgt_idx'
    end

    ## category_classifications
    unless table_exists?(:category_classifications)
      create_table :category_classifications do |t|
        t.integer :category_id
        t.string :classification_type
        t.integer :classification_id
        t.datetime :from_date
        t.datetime :to_date

        t.timestamps
      end

      add_index :category_classifications, [:classification_id, :classification_type], :name => "classification_polymorphic"
      add_index :category_classifications, :category_id, :name => 'category_classifications_category_id_idx'
    end

    ## descriptive_assets
    unless table_exists?(:descriptive_assets)
      create_table :descriptive_assets do |t|
        t.references :view_type
        t.string :internal_identifier
        t.text :description
        t.string :external_identifier
        t.string :external_id_source
        t.references :described_record, :polymorphic => true

        t.timestamps
      end

      add_index :descriptive_assets, :view_type_id
      add_index :descriptive_assets, [:described_record_id, :described_record_type], :name => 'described_record_idx'
      add_index :descriptive_assets, :internal_identifier, :name => 'descriptive_assets_internal_identifier_idx'
    end

    unless table_exists?(:view_types)
      create_table :view_types do |t|
        t.string :internal_identifier
        t.string :description

        t.integer :lft
        t.integer :rgt
        t.integer :parent_id

        t.timestamps
      end

      add_index :view_types, :lft
      add_index :view_types, :rgt
      add_index :view_types, :parent_id
      add_index :view_types, :internal_identifier, :name => 'view_types_internal_identifier_idx'
    end

    unless table_exists?(:geo_countries)
      create_table :geo_countries do |t|
        t.column :name, :string
        t.column :iso_code_2, :string, :length => 2
        t.column :iso_code_3, :string, :length => 3
        t.column :display, :boolean, :default => true
        t.column :external_id, :integer
        t.column :created_at, :datetime
      end
      add_index :geo_countries, :name
      add_index :geo_countries, :iso_code_2
    end

    unless table_exists?(:geo_zones)
      create_table :geo_zones do |t|
        t.column :geo_country_id, :integer
        t.column :zone_code, :string, :default => 2
        t.column :zone_name, :string
        t.column :created_at, :datetime
      end
      add_index :geo_zones, :geo_country_id
      add_index :geo_zones, :zone_name
      add_index :geo_zones, :zone_code
    end

    unless table_exists?(:notes)
      create_table :notes do |t|
        t.text :content
        t.integer :created_by_id
        t.references :noted_record, :polymorphic => true
        t.references :note_type

        t.timestamps
      end

      add_index :notes, [:noted_record_id, :noted_record_type]
      add_index :notes, :note_type_id
      add_index :notes, :created_by_id
    end

    unless table_exists?(:note_types)
      create_table :note_types do |t|
        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.string :description
        t.string :internal_identifier
        t.string :external_identifier
        t.references :note_type_record, :polymorphic => true

        t.timestamps
      end

      add_index :note_types, [:note_type_record_id, :note_type_record_type], :name => "note_type_record_idx"
      add_index :note_types, :parent_id, :name => 'note_types_parent_id_idx'
      add_index :note_types, :internal_identifier, :name => 'note_types_internal_identifier_idx'
    end

    unless table_exists?(:valid_note_types)
      create_table :valid_note_types do |t|
        t.references :valid_note_type_record, :polymorphic => true
        t.references :note_type

        t.timestamps
      end

      add_index :valid_note_types, [:valid_note_type_record_id, :valid_note_type_record_type], :name => "valid_note_type_record_idx"
      add_index :valid_note_types, :note_type_id
    end

    unless table_exists?(:status_applications)
      create_table :status_applications do |t|
        t.references :tracked_status_type
        t.references :status_application_record, :polymorphic => true
        t.datetime :from_date
        t.datetime :thru_date

        t.timestamps
      end

      add_index :status_applications, [:status_application_record_id, :status_application_record_type], :name => 'status_applications_record_idx'
      add_index :status_applications, :tracked_status_type_id, :name => 'tracked_status_type_id_idx'
      add_index :status_applications, :from_date, :name => 'from_date_idx'
      add_index :status_applications, :thru_date, :name => 'thru_date_idx'
    end

    unless table_exists?(:tracked_status_types)
      create_table :tracked_status_types do |t|
        t.string :description
        t.string :internal_identifier
        t.string :external_identifier

        t.integer :lft
        t.integer :rgt
        t.integer :parent_id

        t.timestamps
      end

      add_index :tracked_status_types, :internal_identifier, :name => 'tracked_status_types_iid_idx'
      add_index :tracked_status_types, :lft
      add_index :tracked_status_types, :rgt
      add_index :tracked_status_types, :parent_id
    end

    unless table_exists?(:facilities)
      create_table :facilities do |t|

        t.string :description
        t.string :internal_identifier
        t.integer :facility_type_id
        t.references :postal_address

        #polymorphic columns
        t.integer :facility_record_id
        t.integer :facility_record_type

        t.timestamps
      end

      add_index :facilities, [:facility_record_id, :facility_record_type], :name => "facility_record_idx"
      add_index :facilities, :postal_address_id, :name => "facility_postal_address_idx"
    end

    unless table_exists?(:facility_types)
      create_table :facility_types do |t|

        t.string :description
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_identifer_source

        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.timestamps
      end

      add_index :facility_types, [:parent_id, :lft, :rgt], :name => "facility_types_nested_set_idx"
    end

    unless table_exists?(:fixed_assets)
      create_table :fixed_assets do |t|

        #foreign key references
        t.references :fixed_asset_type

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        #polymorphic columns
        t.string :fixed_asset_record_type
        t.integer :fixed_asset_record_id

        t.timestamps
      end

      add_index :fixed_assets, [:fixed_asset_record_type, :fixed_asset_record_id], :name => "fixed_assets_record_idx"
      add_index :fixed_assets, :fixed_asset_type_id, :name => "fixed_assets_fixed_asset_type_idx"
    end

    unless table_exists?(:fixed_asset_types)
      create_table :fixed_asset_types do |t|
        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end

      add_index :fixed_asset_types, [:parent_id, :lft, :rgt], :name => "fixed_asset_types_nested_set_idx"
    end

    unless table_exists?(:party_fixed_asset_assignments)
      create_table :party_fixed_asset_assignments do |t|
        #foreign key references
        t.references :party
        t.references :fixed_asset

        t.datetime :assigned_from
        t.datetime :assigned_thru
        t.integer :allocated_cost_money_id

        t.timestamps
      end

      add_index :party_fixed_asset_assignments, [:party_id, :fixed_asset_id], :name => "party_fixed_asset_assign_idx"
    end

    unless table_exists?(:fixed_asset_party_roles)
      create_table :fixed_asset_party_roles do |t|

        t.references :party
        t.references :fixed_asset
        t.references :role_type

        t.timestamps
      end
    end

    unless table_exists?(:unit_of_measurements)
      create_table :unit_of_measurements do |t|
        t.string :description
        t.string :domain
        t.string :internal_identifier
        t.string :comments
        t.string :external_identifier
        t.string :external_id_source

        t.integer :lft
        t.integer :rgt
        t.integer :parent_id

        t.timestamps
      end

      add_index :unit_of_measurements, :lft
      add_index :unit_of_measurements, :rgt
      add_index :unit_of_measurements, :parent_id
    end

    unless table_exists?(:generated_items)
      create_table :generated_items do |t|
        t.references :generated_by, :polymorphic => true
        t.references :generated_record, :polymorphic => true

        t.timestamps
      end

      add_index :generated_items, [:generated_by_type, :generated_by_id], :name => 'generated_by_idx'
      add_index :generated_items, [:generated_record_type, :generated_record_id], :name => 'generated_record_idx'
    end

    unless table_exists?(:entity_party_roles)
      create_table :entity_party_roles do |t|
        t.references :party
        t.references :role_type
        t.references :entity_record, :polymorphic => true
      end

      add_index :entity_party_roles, :party_id
      add_index :entity_party_roles, :role_type_id
      add_index :entity_party_roles, [:entity_record_id, :entity_record_type], name: 'entity_party_roles_entity_record_idx'
    end

  end

  def self.down
    [
      :currencies, :money, :compass_ae_instance_party_roles,
      :party_search_facts, :phone_numbers, :email_addresses,
      :postal_addresses, :contact_purposes, :contact_types,
      :contacts, :individuals, :organizations,
      :party_relationships, :relationship_types, :role_types,
      :party_roles, :parties, :categories, :category_classifications,
      :descriptive_assets, :view_types, :notes, :note_types,
      :valid_note_types, :compass_ae_instances,
      :facilities, :facility_types, :fixed_assets,
      :fixed_asset_types, :party_fixed_asset_assignments,
      :unit_of_measurements, :entity_party_roles
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end

  end
end
