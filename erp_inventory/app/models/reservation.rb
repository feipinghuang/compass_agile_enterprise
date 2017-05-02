class Reservation < ActiveRecord::Base
  has_one :inventory_entry
  is_repeatable :starttime, :endtime

  def product_type=(product_type)

  end

  def product_type
    inventory_entry.product_type
  end
end