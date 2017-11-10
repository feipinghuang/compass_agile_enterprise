class Reservation < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_one :inventory_entry

  def product_type=(product_type)

  end

  def product_type
    inventory_entry.product_type
  end
end
