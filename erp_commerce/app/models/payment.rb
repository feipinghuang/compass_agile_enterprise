#### Table Definition ###########################
#  create_table :payments do |t|
#
#     t.column :success,             :boolean
#     t.column :reference_number,    :string
#     t.column :financial_txn_id,    :integer
#     t.column :current_state,       :string
#     t.column :authorization_code,  :string
#     t.string :external_identifier
#
#     t.timestamps
#   end
#
#   add_index :payments, :financial_txn_id
#################################################

class Payment < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  include AASM

  belongs_to :financial_txn, :dependent => :destroy
  has_many   :payment_gateways

  # Get dba_organzation info eventually going to be tenant
  def dba_organization
    self.financial_txn.find_party_by_role('payor').dba_organization
  end
  alias :tenant :dba_organization
  def tenant_id
    tenant.id
  end

  aasm_column :current_state

  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :declined
  aasm_state :authorized
  aasm_state :captured
  aasm_state :refunded
  aasm_state :authorization_reversed
  aasm_state :canceled
  aasm_state :returned

  aasm_event :cancel do
    transitions :to => :canceled, :from => [:pending]
  end

  aasm_event :authorize do
      transitions :to => :authorized, :from => [:pending]
  end

  aasm_event :purchase do
      transitions :to => :captured, :from => [:authorized, :pending]
  end

  aasm_event :decline do
      transitions :to => :declined, :from => [:pending]
  end

  aasm_event :capture do
      transitions :to => :captured, :from => [:authorized, :pending]
  end

  aasm_event :reverse_authorization do
      transitions :to => :authorization_reversed, :from => [:authorized]
  end

  aasm_event :return do
    transitions :to => :returned, :from => [:pending, :captured]
  end

  aasm_event :refund do
    transitions :to => :refunded, :from => [:captured]
  end

end
