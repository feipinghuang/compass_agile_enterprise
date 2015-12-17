class AddDefaultGlAccounts
  
  def self.up
    gl_account_type = BizTxnAcctType.find_or_create('gl_account', 'GL Account')

    BizTxnAcctRoot.create(description: 'Expense',
                          internal_identifier: 'expense',
                          external_identifier: 'expense',
                          biz_txn_acct_type: gl_account_type)

    BizTxnAcctRoot.create(description: 'Revenue',
                          internal_identifier: 'revenue',
                          external_identifier: 'revenue',
                          biz_txn_acct_type: gl_account_type)
  end
  
  def self.down
    BizTxnAcctType.iid('gl_account').destroy
    BizTxnAcctRoot.iid('expense').destroy
    BizTxnAcctRoot.iid('revenue').destroy
  end

end
