class AddOrderTrackedStatues
  
  def self.up
    order_statuses = TrackedStatusType.create(internal_identifier: 'order_statuses', description: 'Order Statuses')
    sales_order_statuses = TrackedStatusType.find_or_create('sales_order_statuses', 'Sales Order Statuses', order_statuses)

    [
        ['sales_order_statuses_initialized', 'Initialized'],
        ['sales_order_statuses_items_added', 'Items Added'],
        ['sales_order_statuses_demographics_gathered', 'Demographics Gathered'],
        ['sales_order_statuses_payment_failed', 'Payment Failed'],
        ['sales_order_statuses_authorized', 'Authorized'],
        ['sales_order_statuses_paid', 'Paid'],
        ['sales_order_statuses_ready_to_ship', 'Ready To Ship'],
        ['sales_order_statuses_shipped', 'Shipped'],
    ].each do |data|
      TrackedStatusType.find_or_create(data[0], data[1], sales_order_statuses)
    end

  end
  
  def self.down
    TrackedStatusType.find_by_internal_identifier('sales_order_statuses').destroy
  end

end
