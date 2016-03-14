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

  tracks_created_by_updated_by

  belongs_to :financial_txn
  belongs_to :payment_applied_to, :polymorphic => true
  belongs_to :money, :foreign_key => 'applied_money_amount_id', :dependent => :destroy

  before_destroy :unapply_payment

  def is_pending?
    self.financial_txn.nil? or (self.financial_txn.is_scheduled? or self.financial_txn.is_pending?) 
  end

  def apply_payment
    #check the calculate balance strategy, if it includes payments then do nothing
    #if it doesn't include payments then update the balance on the model
    unless self.payment_applied_to.calculate_balance_strategy_type.nil?
      unless self.payment_applied_to.calculate_balance_strategy_type.iid =~ /payment/
        update_applied_to_balance(:debit)
      end
    else
      update_applied_to_balance(:debit)
    end
  end

  def unapply_payment
    #check the calculate balance strategy, if it includes payments then do nothing
    #if it doesn't include payments then update the balance on the model
    if self.payment_applied_to.respond_to? :calculate_balance_strategy_type
      if !self.payment_applied_to.calculate_balance_strategy_type.nil?
        if self.payment_applied_to.calculate_balance_strategy_type.iid !=~ /payment/ and !self.is_pending?
          update_applied_to_balance(:credit)
        end
      elsif !self.is_pending?
        update_applied_to_balance(:credit)
      end
    end
  end

  private

  def update_applied_to_balance(type)
    #check if payment_applied_to model has a balance= method
    if self.payment_applied_to.respond_to?(:balance=)
      if type == :debit
        self.payment_applied_to.balance = self.payment_applied_to.balance - self.money.amount
      else
        self.payment_applied_to.balance = self.payment_applied_to.balance + self.money.amount
      end
    end
  end

end
