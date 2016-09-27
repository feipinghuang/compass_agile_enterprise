class AddInvoiceTypes
  
  def self.up
    InvoiceType.create(description: 'Accounts Receivable', internal_identifier: 'acct_receivable')
    InvoiceType.create(description: 'Accounts Payable', internal_identifier: 'acct_payable')
  end
  
  def self.down
    InvoiceType.iid('acct_receivable').destroy
    InvoiceType.iid('acct_payable').destroy
  end

end
