class WorkEffort < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  has_tracked_status

  belongs_to :work_effort_item, :polymorphic => true

  belongs_to :work_effort_type
  belongs_to :work_effort_purpose_type

  ## How is this Work Effort related to Work Order Items (order_line_items)
  has_many :work_order_item_fulfillments, :dependent => :destroy
  has_many :order_line_items, :through => :work_order_item_fulfillments

  ## How is a work effort assigned, it can be assigned to party roles which allow for generic assignment.
  has_and_belongs_to_many :role_types
  alias :role_type_assignments :role_types

  ## How is this Work Effort related to business parties, requestors, workers, approvers
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
      effort.started_at = DateTime.now
      effort.save
    else
      raise 'Effort Already Started'
    end
  end

  def finish
    complete
  end

  def complete
    self.finished_at = Time.now
    self.actual_completion_time = time_diff_in_minutes(self.finished_at.to_time, self.started_at.to_time)
    self.save
  end

  def to_data_hash
    to_hash(only: [{id: 'server_id'}, {'leaf?' => 'leaf'}, 'parent_id', 'description', 'started_at', 'finished_at'])
  end

  protected

  def time_diff_in_minutes (time_one, time_two)
    (((time_one - time_two).round) / 60)
  end
end
