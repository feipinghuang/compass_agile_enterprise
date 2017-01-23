OrderTxn.class_eval do

  # Update inventory based on the order lines in the OrderTxn.  This creates the InventoryTxns but does not apply them
  #
  def update_inventory!
    # TODO this needs to account for inventory at more than one location

    order_line_items.each do |order_line_item|
      if order_line_item.line_item_record.is_a? ProductType
        inventory_entry = order_line_item.line_item_record.inventory_entries.first

      elsif order_line_item.line_item_record.is_a? ProductInstance
        # first try to find inventory on the ProductInstance
        inventory_entry = order_line_item.line_item_record.inventory_entries.first

        # if nothing is found then find it on the Product Type
        unless inventory_entry
          inventory_entry = order_line_item.line_item_record.product_type.inventory_entries.first
        end

      elsif order_line_item.line_item_record.is_a? ProductOffer
        inventory_entry = order_line_item.line_item_record.product_type.inventory_entries.first

      end

      if inventory_entry
        order_line_item.inventory_txns.create!(
          quantity: (0 - order_line_item.quantity),
          is_sell: true,
          comments: "Online Sale #{self.description}",
          inventory_entry: inventory_entry,
          tenant_id: self.find_party_by_role('order_roles_dba_org').id
        )
      end

    end # order_line_items.each

  end # update_inventory

  # Apply any InventoryTxns associated to the OrderLineItems in this OrderTxn
  #
  def apply_inventory!
    # TODO this needs to account for inventory at more than one location

    order_line_items.each do |order_line_item|
      order_line_item.inventory_txns.each do |inventory_txn|
        inventory_txn.apply!
      end
    end # order_line_items.each
  end

  # Unapply any InventoryTxns associated to the OrderLineItems in this OrderTxn
  #
  def unapply_inventory!
    # TODO this needs to account for inventory at more than one location

    order_line_items.each do |order_line_item|
      order_line_item.inventory_txns.each do |inventory_txn|
        inventory_txn.unapply!
      end
    end # order_line_items.each
  end

end # class_eval

module ErpInventory
  module Extensions
    module OrderTxnExtension

      @@order_status_shipped_iids = ['sales_order_statuses_shipped']

      # set current status of entity.
      #
      # This is overriding the default method to apply any inventory if a status of shipped is set and
      # unapply inventory if it is updated from shipped
      #
      # @param args [String, TrackedStatusType, Array] This can be a string of the internal identifier of the
      # TrackedStatusType to set, a TrackedStatusType instance, or three params the status, options and party_id
      def current_status=(args)
        if args.is_a?(Array)
          status = args[0]
        else
          status = args
        end

        tracked_status_type = status.is_a?(TrackedStatusType) ? status : TrackedStatusType.find_by_internal_identifier(status.to_s)
        raise "TrackedStatusType does not exist #{status.to_s}" unless tracked_status_type

        # if passed status is current status then do nothing
        unless self.current_status_type && (self.current_status_type.id == tracked_status_type.id)
          if self.current_status_type
            _current_status = self.current_status_type.internal_identifier
          else
            _current_status = nil
          end
          super(args)

          if args.is_a?(Array)
            status = args[0]
          else
            status = args
          end

          if status.is_a? TrackedStatusType
            status = status.internal_identifier
          end

          if @@order_status_shipped_iid.include?(status)
            self.apply_inventory!
          else
            # if there were InventoryTxns that were applied and this task went from complete to pending we
            # need to unapply those InventoryTxns
            if _current_status && @@order_status_shipped_iid.include?(_current_status)
              self.unapply_inventory!
            end
          end
        end
      end

    end # OrderTxnExtension
  end # Extensions
end # ErpInventory

OrderTxn.prepend ErpInventory::Extensions::OrderTxnExtension
