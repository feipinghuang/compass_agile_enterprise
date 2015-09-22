#### Table Definition ###########################
# create_table "work_efforts", :force => true do |t|
#   t.integer  "parent_id"
#   t.integer  "lft"
#   t.integer  "rgt"
#   t.integer  "facility_id"
#   t.integer  "projected_cost_money_id"
#   t.integer  "actual_cost_money_id"
#   t.integer  "fixed_asset_id"
#   t.integer  "work_effort_purpose_type_id"
#   t.integer  "work_effort_type_id"
#   t.string   "description"
#   t.string   "type"
#   t.datetime "start_at"
#   t.datetime "end_at"
#   t.integer  "work_effort_record_id"
#   t.string   "work_effort_record_type"
#   t.integer  "work_effort_item_id"
#   t.string   "work_effort_item_type"
#   t.datetime "created_at", :null => false
#   t.datetime "updated_at", :null => false
#   t.text     "comments"
#   t.integer  "percent_done"
#   t.integer  "duration"
#   t.string   "duration_unit"
#   t.integer  "effort"
#   t.string   "effort_unit"
#   t.datetime "base_line_start_at"
#   t.datetime "base_line_end_at"
#   t.integer  "base_line_percent_done"
#   t.integer  "project_id"
#   t.text     "custom_fields"
# end
#
# add_index "work_efforts", ["end_at"], :name => "index_work_efforts_on_end_at"
# add_index "work_efforts", ["fixed_asset_id"], :name => "index_work_efforts_on_fixed_asset_id"
# add_index "work_efforts", ["project_id"], :name => "work_effort_project_idx"
# add_index "work_efforts", ["work_effort_item_type", "work_effort_item_id"], :name => "work_item_idx"
# add_index "work_efforts", ["work_effort_record_id", "work_effort_record_type"], :name => "work_effort_record_id_type_idx"
#################################################

class WorkEffort < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  has_tracked_status

  ## How is this Work Effort related to business parties, requestors, workers, approvers
  has_party_roles

  belongs_to :work_effort_item, :polymorphic => true

  belongs_to :project
  belongs_to :work_effort_type
  belongs_to :work_effort_purpose_type

  ## How is this Work Effort related to Work Order Items (order_line_items)
  has_many :work_order_item_fulfillments, :dependent => :destroy
  has_many :order_line_items, :through => :work_order_item_fulfillments

  ## How is a work effort assigned, it can be assigned to party roles which allow for generic assignment.
  has_and_belongs_to_many :role_types
  alias :role_type_assignments :role_types

  ## How is this Work Effort is assigned
  has_many :work_effort_party_assignments, :dependent => :destroy
  has_many :parties, :through => :work_effort_party_assignments do
    def work_resources
      where('work_effort_party_assignments.role_type_id' => RoleType.iid('work_resource'))
    end
  end

  ## What Inventory Items are used in the execution of this Work Effort
  has_many :work_effort_inventory_assignments, :dependent => :destroy
  has_many :inventory_entries, :through => :work_effort_inventory_assignments

  ## What Fixed Assets (tools, equipment) are used in the execution of this Work Effort
  has_many :work_effort_fixed_asset_assignments, :dependent => :destroy
  has_many :fixed_assets, :through => :work_effort_fixed_asset_assignments

  ## What BizTxnEvents have been related to this WorkEffort
  has_many :work_effort_biz_txn_events, :dependent => :destroy
  has_many :biz_txn_events, :through => :work_effort_biz_txn_events

  ## Allow for polymorphic subtypes of this class
  belongs_to :work_effort_record, :polymorphic => true

  belongs_to :projected_cost, :class_name => 'Money', :foreign_key => 'projected_cost_money_id'
  belongs_to :actual_cost, :class_name => 'Money', :foreign_key => 'actual_cost_money_id'
  belongs_to :facility

  has_many :time_entries

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

    # scope by project
    #
    # @param project [Integer | Project | Array] either a id of Project record, a Project record, an array of Project records
    # or an array of Project ids
    #
    # @return [ActiveRecord::Relation]
    def scope_by_project(project)
      where(project_id: project)
    end

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

      statement = joins("inner join entity_party_roles as \"#{table_alias}\" on \"#{table_alias}\".entity_record_id = work_efforts.id")
                      .where("#{table_alias}.party_id" => party).uniq

      if options[:role_types]
        statement = statement.where("#{table_alias}.role_type_id" => RoleType.find_child_role_types(options[:role_types]))
      end

      statement
    end

    # scope by work efforts assigned to the passed user
    #
    # @param user [User] user to look for assignments
    # @param options [Hash] options to apply to this scope
    # @option options [Array] :role_types role types to include in the scope
    #
    # @return [ActiveRecord::Relation]
    def scope_by_user(user, options={})
      statement = joins("join work_effort_party_assignments wepa on wepa.work_effort_id = work_efforts.id and wepa.party_id = #{user.party.id}")


      if options[:role_types]
        statement = statement.where("wepa.role_type_id" => RoleType.find_child_role_types(options[:role_types]))
      end

      statement
    end
  end

  # override for comparison of a work_effort
  #
  # @param an_other [WorkEffort] other work_effort
  # @return [Integer] order
  def <=>(an_other)
    case an_other.current_status
      when 'pending'
        1
      when 'complete'
        2
      else
        3
    end
  end

  # get assigned parties by role type
  #
  # @param role_type [String] role type internal identifier, defaults to worker
  # @return [Array] descriptions of role types comma separated
  def assigned_parties(role_type='worker')
    self.work_effort_party_assignments.where('role_type_id = ?', RoleType.iid(role_type)).collect do |item|
      item.party.description
    end.join(',')
  end

  # get all the assigned roles
  #
  # @return [Array] descriptions of role types comma separated
  def assigned_roles
    self.role_types.collect(&:description).join(',')
  end

  # get the current status of this work_effort
  #
  # @return [String] status
  def status
    current_status
  end

  # return true if this effort has been started, false otherwise
  #
  # @return [Boolean] true if started
  def started?
    current_status.nil? ? false : true
  end

  # return true if this effort has been completed, false otherwise
  #
  # @return [Boolean] true if completed
  def completed?
    finished_at.nil? ? false : true
  end

  # return true if this effort has been completed, false otherwise
  #
  # @return [Boolean]
  def finished?
    completed?
  end

  # start work effort with initial_status (string)
  #
  # @param initial_status [String] status to start at
  def start(initial_status='')
    effort = self
    unless self.descendants.flatten!.nil?
      children = self.descendants.flatten
      effort = children.last
    end

    if current_status.nil?
      effort.current_status = initial_status
      effort.started_at = DateTime.now
      effort.save
    else
      raise 'Effort Already Started'
    end
  end

  # set status to complete
  #
  def finish
    complete
  end

  # completes work effort by setting finished at to Time.now and calculates
  # actual_completion_time in minutes
  #
  def complete
    self.finished_at = Time.now
    self.actual_completion_time = time_diff_in_minutes(self.finished_at.to_time, self.started_at.to_time)
    self.save
  end

  # get total hours for this WorkEffort by TimeEntries
  #
  def total_hours_in_seconds
    time_entries.sum(:regular_hours_in_seconds)
  end

  # get total hours for this WorkEffort by TimeEntries
  def total_hours
    time_entries.all.sum{|time_entry| time_entry.hours }
  end

  # converts this record a hash data representation
  #
  # @return [Hash] data of record
  def to_data_hash
    to_hash(only: [
                :id,
                {leaf?: :leaf},
                :parent_id,
                :description,
                :start_at,
                :end_at,
                :percent_done,
                :duration,
                :duration_unit,
                :effort,
                :effort_unit,
                :comments,
                :sequence,
                :created_at,
                :updated_at
            ]
    )
  end

  protected

  # determine difference in minutes between two times
  #
  # @param time_one [Time] first time
  # @param time_two [Time] second time
  # @return [Integer] time difference in minutes
  def time_diff_in_minutes (time_one, time_two)
    (((time_one - time_two).round) / 60)
  end
end
