require 'ruleby'
include Ruleby

class ReservationRequest < ActiveRecord::Base
  belongs_to :inventory_entry
  belongs_to :product_type

  is_repeatable :starttime, :endtime

  validate :check_availability

  private

  def check_availability
    inventory_entries = InventoryEntry.where(starttime: starttime, endtime: endtime, product_type_id: product_type)

    engine :engine do |e|
      Rulebook::ReservationRulebook.new([SimpleIncrement.new(false, {max_num: 1}, e)], {}, e).rules

      inventory_entries.each {|o| e.assert o}
      Reservation.all.each {|o| e.assert o}
      e.assert SimpleIncrementSet.new

      e.match
    end

    inventory_entries.reject! {|o| o.unavailable}

    if inventory_entries.length < 1
      errors[:base] << 'No matching availability.'
    else
      # make reservation
    end
  end
end