# require 'ruleby'
# include Ruleby
#
# class InventoryEntryKlass
#   def initialize(service_instance, max_reservations)
#     @service_instance = service_instance
#     @max_reservations = max_reservations
#     @number_reservations = nil
#   end
#
#   attr_accessor :service_instance, :max_reservations, :number_reservations
# end
#
# class ServiceInstanceKlass
# end
#
# class ReservationKlass
#   def initialize(inventory_entry)
#     @inventory_entry = inventory_entry
#   end
#
#   attr_accessor :inventory_entry
# end
#
# class ReservationRulebook < Rulebook
#   def rules
#     rule [InventoryEntryKlass, :inventory_entry],
#          [ReservationKlass, :reservation, m.inventory_entry == b(:inventory_entry)] do |v|
#       v[:inventory_entry].number_reservations
#     end
#     rule [ServiceInstanceKlass, :service_instance],
#          [InventoryEntryKlass, :inventory_entry, m.service_instance == b(:service_instance)] do |v|
#       puts 'Got one'
#     end
#   end
# end
#
# service_a = ServiceInstanceKlass.new
# inventory_entry_a = InventoryEntryKlass.new(service_a)
#
# engine :engine do |e|
#   ReservationRulebook.new(e).rules
#   e.assert service_a
#   e.assert inventory_entry_a
#   e.match
# end