class AddDefaultGlAccounts

  def self.up
    gl_account_type = BizTxnAcctType.find_or_create('gl_account', 'GL Account')

    expense = BizTxnAcctRoot.create(description: 'Expense',
                                    internal_identifier: 'expense',
                                    external_identifier: 'expense',
                                    biz_txn_acct_type_id: gl_account_type.id)

    revenue = BizTxnAcctRoot.create(description: 'Revenue',
                                    internal_identifier: 'revenue',
                                    external_identifier: 'revenue',
                                    biz_txn_acct_type_id: gl_account_type.id)

    # add BizTxnAcctPtyRoles for DBA Organization
    if User.find_by_username('admin')
      dba_organization = User.find_by_username('admin').party.dba_organization

      BizTxnAcctPartyRole.create(biz_txn_acct_root: expense,
                                 party: dba_organization,
                                 biz_txn_acct_pty_rtype: BizTxnAcctPtyRtype.find_or_create('dba_org', 'DBA Organization'))

      BizTxnAcctPartyRole.create(biz_txn_acct_root: revenue,
                                 party: dba_organization,
                                 biz_txn_acct_pty_rtype: BizTxnAcctPtyRtype.find_or_create('dba_org', 'DBA Organization'))
    end
  end

  def self.down
  end

end