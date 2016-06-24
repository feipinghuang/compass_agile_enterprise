### Table Definition ###############################
#  create_table :credit_card_accounts do |t|
#    t.timestamps
#  end
####################################################

class CreditCardAccount < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_biz_txn_account

  belongs_to :credit_card_account_purpose
  has_one    :credit_card_account_party_role, :dependent => :destroy
  has_one    :credit_card, :through => :credit_card_account_party_role

  def account_number
    self.credit_card.card_number
  end

  def financial_txns
    self.biz_txn_events.where('biz_txn_record_type = ?', 'FinancialTxn').collect(&:biz_txn_record)
  end

  def successful_payments
    payments = []
    self.financial_txns.each do |financial_txn|
      payments << financial_txn.payments.last if financial_txn.has_captured_payment?
    end
    payments
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def authorize(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use

    result = gateway_wrapper.authorize(credit_card_to_use, financial_txn.money.amount, cvv, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  # purchase with credit card associated to this CreditCardAccount
  def authorize_with_existing_card(financial_txn, gateway_wrapper, gateway_options={})
    result = gateway_wrapper.authorize_with_existing_card(self.credit_card, financial_txn.money.amount, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def purchase(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use

    result = gateway_wrapper.purchase(credit_card_to_use, financial_txn.money.amount, cvv, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  # purchase with credit card associated to this CreditCardAccount
  def purchase_with_existing_card(financial_txn, gateway_wrapper, gateway_options={})
    result = gateway_wrapper.purchase_with_existing_card(self.credit_card, financial_txn.money.amount, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  # purchase with credit card associated to this CreditCardAccount
  def refund(financial_txn, gateway_wrapper, gateway_options={}, amount=nil)
    if amount.nil?
      amount = financial_txn.money.amount
    end

    gateway_wrapper.refund(financial_txn.most_recent_payment, amount, gateway_options)
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def capture(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use

    result = {:success => true}
    payment = Payment.where("current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, financial_txn.id).order('created_at desc').first
    #only capture this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      gateway_options[:debug] = true
      result = gateway_wrapper.capture(credit_card_to_use, payment, cvv, gateway_options)
    end
    result
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def reverse_authorization(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use

    result = {:success => true}
    payment = Payment.where("current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, financial_txn.id).order('created_at desc').first
    #only reverse this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      gateway_options[:debug] = true
      gateway_options[:amount] = financial_txn.money.amount
      result = gateway_wrapper.full_reverse_of_authorization(credit_card_to_use, payment, cvv, gateway_options)
    end
    result
  end

  def void
    # implement a void transaction of a transaction
  end

  #params
  #financial_txn
  #gateway_wrapper
  #
  #Optional
  #money_amount: amount to refund may be less than amount originally charged, so money_amount param is optional
  #gateway_options
  #credit_card_to_use
  def void_or_return(financial_txn, gateway_wrapper, money_amount = nil, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use
    result = {:success => true}

    if money_amount == nil
      money_amount = financial_txn.money.amount
    end
    payment = Payment.where("reference_number = ? and financial_txn_id = ?",gateway_options[:ReferenceNumber], financial_txn.id).order('created_at desc').first
    gateway_options[:debug] = true
    result = gateway_wrapper.void_or_return(credit_card_to_use, payment, money_amount, gateway_options)

    result
  end

end
