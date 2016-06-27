namespace :erp_orders do
  desc "upgrade instance"
  namespace :upgrade do
    task :v2 => :environment do

      puts 'Update Order Statuses'
      unless TrackedStatusType.iid('order_statuses_authorized')
        order_statuses = TrackedStatusType.iid('order_statuses')

        %w{initialized items_added demographics_gathered payment_failed paid ready_to_ship shipped}.each do |status_iid|
          status = TrackedStatusType.iid(status_iid)
          status.internal_identifier = "order_statuses_#{status_iid}"
          status.save!
        end

        TrackedStatusType.find_or_create('order_statuses_authorized', 'Authorized', order_statuses)
      end

    end # v2
  end # upgrade
end # erp_orders
