# create_table :inventory_txns do |t|
#   t.references :fixed_asset
#   t.references :inventory_entry

#   t.decimal :quantity
#   t.decimal :acutal_quantity
#   t.text :comments
#   t.boolean :is_sell
#   t.boolean :applied, default: false
#   t.datetime :applied_at

#   t.integer :created_by_id
#   t.string  :created_by_type
#

#   t.integer :tenant_id

#   t.text :custom_fields

# end

# add_index :inventory_txns, :fixed_asset_id, name: 'inv_txn_fixed_asset_idx'
# add_index :inventory_txns, :inventory_entry_id, name: 'inv_txn_inv_entry_idx'
# add_index :inventory_txns, :tenant_id, name: 'inv_txn_tenant_id_idx'

class InventoryTxn < ActiveRecord::Base
  attr_protected :created_at, :upated_at

  acts_as_biz_txn_event
  is_tenantable

  belongs_to :fixed_asset
  belongs_to :inventory_entry
  belongs_to :created_by, polymorphic: true

  after_create :update_inventory_available!
  before_destroy :unapply!, :revert_inventory_available!

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      unless statement
        statement = InventoryTxn
      end

      if filters[:id]
        statement = statement.where(id: filters[:id])
      end

      statement
    end
  end

  # Update number_available on InventoryEntry.
  #
  def update_inventory_available!
    # if quantity is less than 0 then we are removing inventory and it needs to be
    # removed here
    if self.quantity < 0
      inventory_entry.number_available += self.quantity
      inventory_entry.save!
    end

    if is_sell?
      inventory_entry.number_sold += (0 - self.quantity)
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

    if is_sell?
      inventory_entry.number_sold -= (0 - self.quantity)
      inventory_entry.save!
    end
  end

  # Apply the transaction to the assoicated inventory
  #
  def apply!
    unless self.applied
      inventory_entry.number_in_stock += self.quantity
      inventory_entry.save!

      # if quantity is greater than 0 then we are adding inventory and it needs to be
      # added here
      if self.quantity > 0
        inventory_entry.number_available += self.quantity
        inventory_entry.save!
      end

      self.applied = true
      self.applied_at = Time.now
      self.save!
    end
  end

  # Unapply the transaction to the assoicated inventory
  #
  def unapply!
    if self.applied
      inventory_entry.number_in_stock -= self.quantity
      inventory_entry.save!

      if self.quantity > 0
        inventory_entry.number_available -= self.quantity
        inventory_entry.save!
      end

      if is_sell?
        inventory_entry.number_sold -= (0 - self.quantity)
        inventory_entry.save!
      end

      self.applied = false
      self.applied_at = nil
      self.save!
    end
  end

  def to_data_hash
    data = to_hash(only: [
                       :id,
                       :quantity,
                       :acutal_quantity,
                       :comments,
                       :applied,
                       :applied_at
                   ],
                   fixed_asset: fixed_asset.description,
                   product_description: inventory_entry.description)



    data
  end


end
