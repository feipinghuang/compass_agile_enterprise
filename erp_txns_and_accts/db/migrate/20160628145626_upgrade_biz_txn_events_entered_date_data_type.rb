class UpgradeBizTxnEventsEnteredDateDataType < ActiveRecord::Migration
  def up
    if column_exists?(:biz_txn_events, :entered_date)
      change_column :biz_txn_events, :entered_date, :date if BizTxnEvent.columns_hash['entered_date'].type == :datetime
    end

    if column_exists?(:biz_txn_events, :post_date)
      change_column :biz_txn_events, :post_date, :date if BizTxnEvent.columns_hash['post_date'].type == :datetime
    end
  end
  
  def down
    if column_exists?(:biz_txn_events, :entered_date)
      change_column :biz_txn_events, :entered_date, :datetime if BizTxnEvent.columns_hash['entered_date'].type == :date
    end

    if column_exists?(:biz_txn_events, :post_date)
      change_column :biz_txn_events, :post_date, :datetime if BizTxnEvent.columns_hash['post_date'].type == :date
    end
  end
end
