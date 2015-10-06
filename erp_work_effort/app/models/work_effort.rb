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
# add_index "work_efforts", ["end_at"], :name => "index_work_efforts_on_finished_at"
# add_index "work_efforts", ["fixed_asset_id"], :name => "index_work_efforts_on_fixed_asset_id"
# add_index "work_efforts", ["project_id"], :name => "work_effort_project_idx"
# add_index "work_efforts", ["work_effort_item_type", "work_effort_item_id"], :name => "work_item_idx"
# add_index "work_efforts", ["work_effort_record_id", "work_effort_record_type"], :name => "work_effort_record_id_type_idx"

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
  has_many :parties, :through => :work_effort_party_assignments

  ## What Inventory Items are used in the execution of this Work Effort
  has_many :work_effort_inventory_assignments, :dependent => :destroy
  has_many :inventory_entries, :through => :work_effort_inventory_assignments

  ## What Fixed Assets (tools, equipment) are used in the execution of this Work Effort
  has_many :work_effort_fixed_asset_assignments, :dependent => :destroy
  has_many :fixed_assets, :through => :work_effort_fixed_asset_assignments

  ## Allow for polymorphic subtypes of this class
  belongs_to :work_effort_record, :polymorphic => true

  belongs_to :projected_cost, :class_name => 'Money', :foreign_key => 'projected_cost_money_id'
  belongs_to :actual_cost, :class_name => 'Money', :foreign_key => 'actual_cost_money_id'
  belongs_to :facility

  class << self
    def work_efforts_for_party(party, status=nil)
      role_types_tbl = RoleType.arel_table
      parties_tbl = Party.arel_table

      statement = self

      # apply status if passed
      statement = statement.with_status(status) if status

      statement.includes(:role_types)
          .includes(:parties)
          .where(role_types_tbl[:id].in(party.party_roles.collect(&:role_type_id)).or(parties_tbl[:id].eq(party.id)))
    end
  end

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

  def assigned_parties(role_type='worker')
    self.work_effort_party_assignments.where('role_type_id = ?', RoleType.iid(role_type)).collect do |item|
      item.party.description
    end.join(',')
  end

  def assigned_roles
    self.role_types.collect(&:description).join(',')
  end

  def status
    # get status via has_tracked_status
    current_status
  end

  # return true if this effort has been started, false otherwise
  def started?
    current_status.nil? ? false : true
  end

  # return true if this effort has been completed, false otherwise
  def completed?
    finished_at.nil? ? false : true
  end

  def finished?
    completed?
  end

  #start work effort with initial_status (string)
  def start(initial_status='')
    effort = self
    unless self.descendants.flatten!.nil?
      children = self.descendants.flatten
      effort = children.last
    end

    if current_status.nil?
      effort.current_status = initial_status
      effort.start_at = DateTime.now
      effort.save
    else
      raise 'Effort Already Started'
    end
  end

  def finish
    complete
  end

  def complete
    self.end_at = Time.now
    self.actual_completion_time = time_diff_in_minutes(self.end_at.to_time, self.start_at.to_time)
    self.save
  end

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

  def time_diff_in_minutes (time_one, time_two)
    (((time_one - time_two).round) / 60)
  end
end
