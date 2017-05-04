require 'ruleby'
include Ruleby
require 'set'

class ReservationRulebook < Rulebook
  # rulebooks: array<Rulebook> or False.
  # *args: args for RuleBook superclass
  def initialize(rulebooks, extra_data, *args)
    super(*args)
    @rulebooks  = rulebooks
    @extra_data =  extra_data
  end

  def rules
    !@rulebooks ?
        my_rules :
        my_rules.concat(@rulebooks.reduce([]) {|memo, book| memo += book.rules })
  end

  def my_rules
    []
  end
end

class MaxNumberRulebook < ReservationRulebook
end

class SimpleIncrementSet < Set
end

class SimpleIncrement < MaxNumberRulebook
  def my_rules
    rule [InventoryEntry, :inventory_entry],
         [Reservation, :reservation, method.inventory_entry == b(:inventory_entry)] do |vars|
      vars[:inventory_entry].number_reservations ||= 0
      vars[:inventory_entry].number_reservations += 1
      retract vars[:reservation]
      modify  vars[:inventory_entry]
    end

    rule [InventoryEntry, :inventory_entry, method.number_reservations > @extra_data[:num] ] do |vars|
      vars[:inventory_entry].unavailable = true
    end
  end
end

# engine :engine do |e|
#   ReservationRulebook.new([SimpleIncrement.new(false, {}, e)], {}, e).rules
#
#   inventory_entry = InventoryEntryKlass.new
#   reservation     = ReservationKlass.new
#   reservation2     = ReservationKlass.new
#   reservation3     = ReservationKlass.new
#   reservation.inventory_entry = inventory_entry
#   reservation2.inventory_entry = inventory_entry
#   reservation3.inventory_entry = inventory_entry
#
#   sis = SimpleIncrementSet.new
#
#   e.assert inventory_entry
#   e.assert reservation2
#   e.assert reservation3
#   e.assert reservation
#   e.assert sis
#
#   e.match
# end