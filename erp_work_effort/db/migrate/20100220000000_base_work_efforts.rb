class BaseWorkEfforts < ActiveRecord::Migration

  def self.up

    ##********************************************************************************************
    ## Human resource (Party) skill types
    ##********************************************************************************************
    unless table_exists?(:skill_types)
      create_table :skill_types do |t|
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
    end

    ## party skills
    unless table_exists?(:party_skills)
      create_table :party_skills do |t|
        t.integer :party_id
        t.integer :skill_type_id

        t.timestamps
      end
      add_index :party_skills, [:party_id, :skill_type_id], :name => "party_skills_idx"
    end

    ##********************************************************************************************
    ## Types of goods required as a standard for the completion of work efforts. This is different from
    ## inventory_items because it is not for planning. It is only for noting the type of good
    ## that is required to perform the work effort. - See DMRB v1, pp 223-224
    ##********************************************************************************************
    unless table_exists?(:good_types)
      create_table :good_types do |t|
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
    end

    ##********************************************************************************************
    ## Deliverables - outputs from work efforts
    ##********************************************************************************************
    unless table_exists?(:deliverables)
      create_table :deliverables do |t|

        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        #polymorphic columns
        t.string :deliverable_record_type
        t.integer :deliverable_record_id

        t.timestamps
      end
    end

    # deliverable types
    unless table_exists?(:deliverable_types)
      create_table :deliverable_types do |t|
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
    end

    ##********************************************************************************************
    ## Requirements
    ##********************************************************************************************
    unless table_exists?(:requirements)
      create_table :requirements do |t|

        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.string :description
        t.string :type
        t.integer :projected_completion_time
        t.integer :estimated_budget_money_id

        #requirement type
        t.integer :requirement_type_id
        #polymorphic columns
        t.integer :requirement_record_id
        t.string :requirement_record_type

        #These columns represent optional relationships to the items used by and
        #produced via fulfillment of the requirement
        #TODO if we do separate requirement from work requirement, some of these relationships
        #would get moved to work_requirement or another subtype. See DMRB V1 p187
        t.integer :fixed_asset_id
        t.integer :product_id
        t.integer :deliverable_id

        t.timestamps
      end
    end

    # requirement types. We use polymorphic subtypes
    unless table_exists?(:requirement_types)
      create_table :requirement_types do |t|
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
    end

    # Create requirement_party_roles
    unless table_exists?(:requirement_party_roles)
      create_table :requirement_party_roles do |t|
        t.string :description

        t.integer :requirement_id
        t.integer :party_id
        t.integer :role_type_id

        t.string :external_identifier
        t.string :external_id_source

        t.datetime :valid_from
        t.datetime :valid_to

        t.timestamps
      end
      add_index :requirement_party_roles, [:requirement_id, :party_id, :role_type_id], :name => "requirement_party_roles_idx"
    end

    ##********************************************************************************************
    ## Base Work Effort data structures
    ##********************************************************************************************
    unless table_exists?(:work_efforts)
      create_table :work_efforts do |t|
        #better nested set columns
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #foreign keys
        t.integer :facility_id
        t.integer :projected_cost_money_id
        t.integer :actual_cost_money_id
        t.references :fixed_asset
        t.references :work_effort_purpose_type
        t.references :work_effort_type

        t.string :description
        t.string :type
        t.datetime :started_at
        t.datetime :finished_at
        t.integer :projected_completion_time
        t.integer :actual_completion_time

        #polymorphic columns
        t.integer :work_effort_record_id
        t.string :work_effort_record_type

        t.references :work_effort_item, :polymorphic => true

        t.timestamps
      end
      add_index :work_efforts, [:work_effort_record_id, :work_effort_record_type], :name => "work_effort_record_id_type_idx"
      add_index :work_efforts, [:work_effort_item_type, :work_effort_item_id], :name => 'work_item_idx'
      add_index :work_efforts, :fixed_asset_id
      add_index :work_efforts, :finished_at
    end

    unless table_exists?(:associated_work_efforts)
      create_table :associated_work_efforts do |t|
        #foreign keys
        t.integer :work_effort_id

        #polymorphic columns
        t.integer :associated_record_id
        t.string :associated_record_type
      end
      add_index :associated_work_efforts, [:associated_record_id, :associated_record_type], :name => "associated_record_id_type_idx"
      add_index :associated_work_efforts, :work_effort_id
    end

    ## work_effort types
    unless table_exists?(:work_effort_types)
      create_table :work_effort_types do |t|
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
    end

    # work_effort purpose types - is this work_effort to produce something or repair something?
    unless table_exists?(:work_effort_purpose_types)
      create_table :work_effort_purpose_types do |t|
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
    end

    ## Easy to confuse this with work_effort_type_associations, which are for associations between types of
    ## work efforts used for standards or templates. This is the type used when the actual association is created.
    ## It is still used to store things like dependency and breakdown, but this is the type data and
    ## work_effort_type_associations is used to store valid combinations of work effort types.
    unless table_exists?(:work_effort_association_types)
      create_table :work_effort_association_types do |t|
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.integer :valid_from_role_type_id
        t.integer :valid_to_role_type_id
        t.string :name
        t.string :description

        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
      add_index :work_effort_association_types, :valid_from_role_type_id
      add_index :work_effort_association_types, :valid_to_role_type_id
    end

    ## Work effort associations store precedence, concurrence. They can also store
    ## task breakdowns, but there is a more efficient nested-set data structure directly on the work_effort
    ## for this purpose, since it is common to reconstruct large work breakdown structures
    ## with important read performance requirements
    unless table_exists?(:work_effort_associations)
      create_table :work_effort_associations do |t|
        #foreign key references
        t.references :work_effort_association_type

        t.string :description
        t.integer :work_effort_id_from
        t.integer :work_effort_id_to
        t.integer :role_type_id_from
        t.integer :role_type_id_to
        t.integer :relationship_type_id
        t.datetime :effective_from
        t.datetime :effective_thru

        t.timestamps
      end
      add_index :work_effort_associations, :relationship_type_id
    end

    ##********************************************************************************************
    ## Work Effort Generation (DMRB V1 pp 194-195)
    ##********************************************************************************************
    ## The next three entities represent the relationships between three key entities
    ## order_line_item <==> requirement <==> work_effort (and work_effort <==> order_line_item)

    ## This entity tracks the relationship between the
    ## work_order (order_line_item) and the work_effort by which it is fulfilled.
    unless table_exists?(:work_order_item_fulfillments)
      create_table :work_order_item_fulfillments do |t|
        #foreign key references
        t.references :work_effort
        t.references :order_line_item

        t.string :description

        t.timestamps
      end
      add_index :work_order_item_fulfillments, [:work_effort_id, :order_line_item_id], :name => "work_order_item_fulfillments_idx"
    end

    unless table_exists?(:work_order_items)
      create_table :work_order_items do |t|
        # WorkOrderItem acts_as_order_line_item & polymorphic relationship is on order_line_item so this table only has timestamps
        t.timestamps
      end
    end

    ## relationship to track the relationship between order_line_items and the requirement to fulfill them
    unless table_exists?(:order_requirement_commitments)
      create_table :order_requirement_commitments do |t|
        #foreign key references
        t.references :order_line_item
        t.references :requirement

        t.string :description
        t.integer :quantity

        t.timestamps
      end
      add_index :order_requirement_commitments, [:order_line_item_id, :requirement_id], :name => "order_item_req_fulfillment_idx"
    end

    ## relationship to track the relationship between requirements and the work_efforts to fulfill them
    unless table_exists?(:work_requirement_fulfillment)
      create_table :work_requirement_fulfillment do |t|
        t.string :description

        t.integer :work_effort_id
        t.integer :requirement_id

        t.timestamps
      end
      add_index :work_requirement_fulfillment, [:work_effort_id, :requirement_id], :name => "work_order_req_fulfillment_idx"
    end

    ##********************************************************************************************
    ## Work Effort Assignments - what is necessary to complete this work effort
    ##********************************************************************************************
    ## work_effort_party_assignments
    ## this is straight entity_party_role pattern with from and thru dates, but we are keeping
    ## the DMRB name for this entity.
    unless table_exists?(:work_effort_party_assignments)
      create_table :work_effort_party_assignments do |t|
        #foreign key references
        t.references :work_effort
        t.references :role_type
        t.references :party

        t.datetime :assigned_from
        t.datetime :assigned_thru

        t.text :comments

        t.timestamps
      end
      add_index :work_effort_party_assignments, :assigned_from
      add_index :work_effort_party_assignments, :assigned_thru
      add_index :work_effort_party_assignments, :work_effort_id
      add_index :work_effort_party_assignments, :party_id
    end

    unless table_exists?(:work_effort_fixed_asset_assignments)
      create_table :work_effort_fixed_asset_assignments do |t|
        #foreign key references
        t.references :work_effort
        t.references :fixed_asset

        t.timestamps
      end
      add_index :work_effort_fixed_asset_assignments, [:work_effort_id, :fixed_asset_id], :name => "work_effort_fixed_asset_assign_idx"
    end

    ##********************************************************************************************
    ## Work effort type standards
    ##********************************************************************************************

    ## work_effort type associations - standard for associations between work_efforts
    unless table_exists?(:work_effort_type_associations)
      create_table :work_effort_type_associations do |t|

        #this type field is NOT REDUNDANT. It is here to distinguish between work breakdown type associations and
        #dependency type associations
        t.integer :work_effort_type_assoc_type

        #the two work effort types involved in the association
        t.integer :work_effort_type_id_from
        t.integer :work_effort_type_id_to

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
    end

    unless table_exists?(:work_effort_fixed_asset_standards)
      create_table :work_effort_fixed_asset_standards do |t|
        #foreign key references
        t.references :work_effort
        t.references :fixed_asset_type

        t.decimal :estimated_quantity
        t.decimal :estimated_duration
        t.integer :estimated_cost_money_id

        t.timestamps
      end
      add_index :work_effort_fixed_asset_standards, :work_effort_id
      add_index :work_effort_fixed_asset_standards, :fixed_asset_type_id
    end

    unless table_exists?(:work_effort_skill_standards)
      create_table :work_effort_skill_standards do |t|
        #foreign key references
        t.references :work_effort
        t.references :skill_type

        t.decimal :estimated_num_people
        t.decimal :estimated_duration
        t.integer :estimated_cost_money_id

        t.timestamps
      end
      add_index :work_effort_skill_standards, :work_effort_id
      add_index :work_effort_skill_standards, :skill_type_id
    end

    unless table_exists?(:work_effort_good_standards)
      create_table :work_effort_good_standards do |t|
        #foreign key references
        t.references :work_effort
        t.references :good_type

        t.decimal :estimated_quantity
        t.integer :estimated_cost_money_id

        t.timestamps
      end
      add_index :work_effort_good_standards, :work_effort_id
    end

    ##********************************************************************************************
    ## Work Effort Results
    ##********************************************************************************************
    unless table_exists?(:work_effort_deliverable_produced)
      create_table :work_effort_deliverable_produced do |t|
        #foreign key references
        t.references :work_effort
        t.references :deliverable

        t.timestamps
      end
      add_index :work_effort_deliverable_produced, :work_effort_id
      add_index :work_effort_deliverable_produced, :deliverable_id
    end

    unless table_exists?(:work_effort_fixed_asset_serviced)
      create_table :work_effort_fixed_asset_serviced do |t|
        #foreign key references
        t.references :work_effort
        t.references :fixed_asset

        t.timestamps
      end
      add_index :work_effort_fixed_asset_serviced, :work_effort_id
      add_index :work_effort_fixed_asset_serviced, :fixed_asset_id
    end

    ##********************************************************************************************
    ## TODO - delete these?
    ## Party Resource Availability - NOT IN DMRB, but didn't want to delete without review
    ##********************************************************************************************
    unless table_exists?(:party_resource_availabilities)
      create_table :party_resource_availabilities do |t|
        t.datetime :from_date
        t.datetime :to_date
        t.integer :party_id
        t.integer :pra_type_id #:party_resource_availability_type_id is too long

        t.timestamps
      end
      add_index :party_resource_availabilities, :from_date
      add_index :party_resource_availabilities, :to_date
      add_index :party_resource_availabilities, :pra_type_id
      add_index :party_resource_availabilities, :party_id
    end

    unless table_exists?(:party_resource_availability_types)
      create_table :party_resource_availability_types do |t|
        t.string :description
        t.string :internal_identifier

        t.timestamps
      end
      add_index :party_resource_availability_types, :internal_identifier
      add_index :party_resource_availability_types, :description
    end

    # transportation_routes
    unless table_exists?(:transportation_routes)
      create_table :transportation_routes do |t|

        t.string :internal_identifier
        t.string :description
        t.string :comments

        #connection to external system
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
    end

    # transportation_route_segments
    unless table_exists?(:transportation_route_segments)
      create_table :transportation_route_segments do |t|

        t.string :internal_identifier
        t.string :description
        t.string :comments

        #connection to external system
        t.string :external_identifier
        t.string :external_id_source

        t.integer :sequence
        t.datetime :estimated_start
        t.datetime :estmated_arrival
        t.datetime :actual_start
        t.datetime :actual_arrival
        t.integer :start_mileage
        t.integer :end_milage
        t.integer :fuel_used

        #foreign keys
        t.integer :transportation_route_id
        t.integer :from_transportation_route_stop_id
        t.integer :to_transportation_route_stop_id

        t.timestamps
      end
    end

    # transportation_route_stops
    unless table_exists?(:transportation_route_stops)
      create_table :transportation_route_stops do |t|

        t.string :internal_identifier
        t.string :description

        t.integer :postal_address_id
        t.string :geoloc
        t.integer :sequence

        #connection to external system
        t.string :external_identifier
        t.string :external_id_source

        #foreign keys
        t.integer :transportation_route_id

        t.timestamps
      end
    end

    # associated_transportation_routes
    unless table_exists?(:associated_transportation_routes)
      create_table :associated_transportation_routes do |t|
        #foreign keys
        t.integer :transportation_route_id

        #polymorphic columns
        t.integer :associated_record_id
        t.string :associated_record_type
      end
      add_index :associated_transportation_routes, [:associated_record_id, :associated_record_type], :name => "associated_route_record_id_type_idx"
      add_index :associated_transportation_routes, :transportation_route_id, :name => "associated_route_transportation_route_id_idx"
    end

    unless table_exists?(:role_types_work_efforts)
      create_table :role_types_work_efforts do |t|
        t.references :role_type
        t.references :work_effort
      end

      add_index :role_types_work_efforts, [:role_type_id, :work_effort_id], :name => 'role_type_work_effort_idx'
    end

    ##********************************************************************************************
    ## Positions
    ##********************************************************************************************
    unless table_exists?(:position_types)
      create_table :position_types do |t|

        t.string :description
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_identifer_source

        #these columns are required to support the behavior of the plugin 'awesome_nested_set'
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        t.string :title
        t.decimal :benefit_percent, :precision => 8, :scale => 2

        t.timestamps

      end

      add_index :position_types, :parent_id
      add_index :position_types, :lft
      add_index :position_types, :rgt
    end

    unless table_exists?(:positions)
      create_table :positions do |t|

        t.references    :party
        t.references    :position_type
        t.date          :estimated_from_date
        t.date          :estimated_thru_date
        t.boolean       :salary_flag
        t.boolean       :exempt_flag
        t.boolean       :full_time_flag
        t.boolean       :temporary_flag
        t.date          :actual_from_date
        t.date          :actual_thru_date

        t.timestamps

      end

      add_index :positions, :position_type_id
      add_index :positions, :party_id
    end

    unless table_exists?(:position_fulfillments)
      create_table :position_fulfillments do |t|
        t.string        :description
        t.integer       :held_by_party_id
        t.references    :position
        t.date          :from_date
        t.date          :thru_date
        t.timestamps
      end

      add_index :position_fulfillments, :position_id
      add_index :position_fulfillments, :held_by_party_id
    end

    ##********************************************************************************************
    ## Time Entry
    ##********************************************************************************************
    unless table_exists?(:time_sheet_entries)
      create_table :time_sheet_entries do |t|

        t.references  :work_effort
        t.string      :description
        t.date        :worked_date
        t.datetime    :entered_date
        t.decimal     :regular_hours_worked, :precision => 5, :scale => 2
        t.decimal     :overtime_hours_worked, :precision => 5, :scale => 2
        t.datetime    :start_time
        t.datetime    :end_time
        t.text        :comments

        t.timestamps
      end

      add_index :time_sheet_entries, :work_effort_id
    end

    unless table_exists?(:time_sheet_entry_party_roles)
      create_table :time_sheet_entry_party_roles do |t|

        t.references    :time_sheet_entry
        t.references    :party
        t.references    :role_type

        t.date          :from_date
        t.date          :thru_date

        t.timestamps
      end

      add_index :time_sheet_entry_party_roles, :time_sheet_entry_id
      add_index :time_sheet_entry_party_roles, :party_id
      add_index :time_sheet_entry_party_roles, :role_type_id
    end

    unless table_exists?(:experiences)
      create_table :experiences do |t|

        t.string :description

        t.timestamps
      end
    end

  end

  def self.down
    [
        :good_types,

        #hr-skills
        :skill_types,
        :party_skills,

        #deliverables
        :deliverables,
        :deliverable_types,

        #requirements
        :requirements,
        :requirement_types,
        :requirement_party_roles,

        #work effort data structures
        :work_efforts,
        :work_effort_types,
        :work_effort_purpose_types,
        :work_effort_association_types,
        :work_effort_associations,
        :associated_work_efforts,

        #work_effort generation
        :work_order_item_fulfillment,
        :work_order_items,
        :order_requirement_commitments,
        :work_requirement_fulfillment,

        #assignments
        :work_effort_party_assignments,
        :work_effort_fixed_asset_assignments,

        ##standards
        :work_effort_type_associations,
        :work_effort_fixed_asset_standards,
        :work_effort_skill_standards,
        :work_effort_good_standards,

        ##results
        :work_effort_deliverable_produced,
        :work_effort_fixed_asset_serviced,

        ##obsolete??
        :party_resource_availabilities,
        :party_resource_availability_types,

        ## routing
        :transportation_routes,
        :transportation_route_segments,
        :transportation_route_stops,
        :associated_transportation_routes,

        :role_types_work_efforts,

        :position_types, :positions,
        :position_fulfillments,
        :time_sheet_entries,
        :time_sheet_entry_party_roles,
        :experiences

    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end

end
