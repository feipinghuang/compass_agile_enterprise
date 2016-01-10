class AddPaymentTransactionTypes
  
  def self.up
    payment_transactions = BizTxnType.find_or_create('payment_transaction', 'Payment Transaction')
    BizTxnType.find_or_create('credit_card', 'Credit Card', payment_transactions)
    BizTxnType.find_or_create('cash', 'Cash', payment_transactions)
    BizTxnType.find_or_create('pay_pal', 'PayPal', payment_transactions)
  end
  
  def self.down
    BizTxnType.iid('payment_transaction').destroy
  end

end
