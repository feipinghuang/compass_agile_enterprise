Party.class_eval do
  has_many :order_line_item_pty_roles

  def orders(statuses=[])
    statement = OrderTxn

    unless statuses.empty?
      statement = statement.with_current_status({'sales_order_statuses' => statuses})
    end

    statement = statement.joins(:biz_txn_event => :biz_txn_party_roles)
            .where(:biz_txn_party_roles => {:party_id => self.id})

    statement
  end
end
