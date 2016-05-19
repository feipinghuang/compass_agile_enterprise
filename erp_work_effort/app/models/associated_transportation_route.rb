# create_table :associated_transportation_routes do |t|
#   t.integer :transportation_route_id
#   t.integer :associated_record_id
#   t.string :associated_record_type
# end
#
# add_index :associated_transportation_routes, [:associated_record_id, :associated_record_type], :name => "associated_route_record_id_type_idx"
# add_index :associated_transportation_routes, :transportation_route_id, :name => "associated_route_transportation_route_id_idx"

class AssociatedTransportationRoute < ActiveRecord::Base
	attr_protected :created_at, :updated_at

  belongs_to :transportation_route
  belongs_to :associated_record, :polymorphic => true
end