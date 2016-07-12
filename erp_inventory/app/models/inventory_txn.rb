class InventoryTxn < ActiveRecord::Base
  attr_protected :created_at, :upated_at

  acts_as_biz_txn_event
  is_tenantable

  belongs_to :fixed_asset
  belongs_to :inventory_entry
  belongs_to :unit_of_measurement

  after_create :update_inventory_available!
  before_destroy :unapply!, :revert_inventory_available!

  # Update number_available on InventoryEntry.
  # If the quantity is < 0 then update number available as it will be used
  #
  def update_inventory_available!
    if self.quantity < 0
      inventory_entry.number_available += self.quantity
      inventory_entry.save!
    end
  end

  # Revert the update on number_available on InventoryEntry
  #
  def revert_inventory_available!
    if applied
      inventory_entry.number_available -= self.quantity
      inventory_entry.save!
    end
  end

  # Apply the transaction to the assoicated inventory
  #
  def apply!
    inventory_entry.number_in_stock += self.quantity
    inventory_entry.save!

    if self.quantity > 0
      inventory_entry.number_available += self.quantity
      inventory_entry.save!
    end

    self.applied = true
    self.applied_at = Time.now
    self.save!

  end

  # Unapply the transaction to the assoicated inventory
  #
  def unapply!
    inventory_entry.number_in_stock -= self.quantity
    inventory_entry.save!

    if self.quantity > 0
      inventory_entry.number_available -= self.quantity
      inventory_entry.save!
    end

    self.applied = false
    self.applied_at = nil
    self.save!
  end

end
