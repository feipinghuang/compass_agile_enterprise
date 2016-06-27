class AddOrderTrackedStatues
  
  def self.up
    order_statuses = TrackedStatusType.create(internal_identifier: 'order_statuses', description: 'Order Statuses')

    [
        ['order_statuses_initialized', 'Initialized'],
        ['order_statuses_items_added', 'Items Added'],
        ['order_statuses_demographics_gathered', 'Demographics Gathered'],
        ['order_statuses_payment_failed', 'Payment Failed'],
        ['order_statuses_authorized', 'Authorized'],
        ['order_statuses_paid', 'Paid'],
        ['order_statuses_ready_to_ship', 'Ready To Ship'],
        ['order_statuses_shipped', 'Shipped'],
    ].each do |data|
      status = TrackedStatusType.create(internal_identifier: data[0], description: data[1])
      status.move_to_child_of(order_statuses)
    end

  end
  
  def self.down
    TrackedStatusType.find_by_internal_identifier('order_statuses').destroy
  end

end
