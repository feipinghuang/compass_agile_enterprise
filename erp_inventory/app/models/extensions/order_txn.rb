OrderTxn.class_eval do

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
        inventory_txn = InventoryTxn.create!(
          quantity: (0 - order_line_item.quantity),
          is_sell: true,
          comments: 'Online Sale',
          inventory_entry: inventory_entry,
          tenant_id: self.find_party_by_role('order_roles_dba_org').id
        )

        inventory_txn.associate_to_order(self)
      end

    end # order_line_items.each

  end # update_inventory

end # class_eval
