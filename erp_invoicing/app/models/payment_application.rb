## Schema Definition ################################################
#  create_table "payment_applications", :force => true do |t|
#    t.integer  "financial_txn_id"
#    t.integer  "payment_applied_to_id"
#    t.string   "payment_applied_to_type"
#    t.integer  "applied_money_amount_id"
#    t.string   "comment"
#    t.datetime "created_at",              :null => false
#    t.datetime "updated_at",              :null => false
#    end
#
#    add_index "payment_applications", ["applied_money_amount_id"], :name => "index_payment_applications_on_applied_money_amount_id"
#    add_index "payment_applications", ["financial_txn_id"], :name => "index_payment_applications_on_financial_txn_id"
#    add_index "payment_applications", ["payment_applied_to_id", "payment_applied_to_type"], :name => "payment_applied_to_idx"
#
######################################################################

class PaymentApplication < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_file_assets
  tracks_created_by_updated_by

  belongs_to :financial_txn
  belongs_to :payment_applied_to, :polymorphic => true
  belongs_to :money, :foreign_key => 'applied_money_amount_id', :dependent => :destroy

  before_destroy :unapply_payment

  def is_pending?
    self.financial_txn.nil? or (self.financial_txn.is_scheduled? or self.financial_txn.is_pending?)
  end

  def refund
  	financial_txn.refund
  end

  def apply_payment
    # hook method to be extended
  end

  def unapply_payment
    # If this payment was on an Invoice or Bill update its status
    #
    if payment_applied_to.is_a? Invoice
      if payment_applied_to.invoice_type.internal_identifier == 'acct_receivable'
        payment_applied_to.current_status = 'invoice_statuses_sent'
      elsif payment_applied_to.invoice_type.internal_identifier == 'acct_payable'
        payment_applied_to.current_status = 'bill_statuses_open'
      end
    end
  end

end
