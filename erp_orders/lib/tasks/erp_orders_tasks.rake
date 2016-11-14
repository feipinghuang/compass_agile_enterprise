namespace :erp_orders do
  desc "upgrade instance"
  namespace :upgrade do
    task :v2 => :environment do

      puts 'Update Order Statuses'
      if !TrackedStatusType.iid('order_statuses_items_added') && !TrackedStatusType.iid('sales_order_statuses_items_added')
        order_statuses = TrackedStatusType.iid('order_statuses')

        %w{initialized items_added demographics_gathered payment_failed paid ready_to_ship shipped}.each do |status_iid|
          status = TrackedStatusType.iid(status_iid)
          status.internal_identifier = "order_statuses_#{status_iid}"
          status.save!
        end

        TrackedStatusType.find_or_create('order_statuses_authorized', 'Authorized', order_statuses)
      end

      puts "Add sales order statuses"

      unless TrackedStatusType.iid('sales_order_statuses')
        order_statuses = TrackedStatusType.find_or_create('order_statuses', 'Order Statuses')
        sales_order_statues = TrackedStatusType.find_or_create('sales_order_statuses', 'Sales Order Statuses', order_statuses)

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

          current_status = TrackedStatusType.find_or_create(data[0], data[1])

          current_status.internal_identifier = "sales_#{iid}"
          current_status.save!

          current_status.move_to_child_of(sales_order_statues)

        end

      end # Update order statuses

      puts "Update work order statuses"

      TrackedStatusType.iid('work_order_statuses').move_to_child_of(TrackedStatusType.find_or_create('order_statuses', 'Order Statuses'))
      unless TrackedStatusType.iid('work_order_statuses_complete')
        TrackedStatusType.find_or_create('work_order_statuses_complete', 'Complete', TrackedStatusType.iid('work_order_statuses'))
      end

    end # v2
  end # upgrade
end # erp_orders
