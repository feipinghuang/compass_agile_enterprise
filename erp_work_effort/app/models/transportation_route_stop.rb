# create_table :transportation_route_stops do |t|
#
#   t.string :internal_identifier
#   t.string :description
#
#   t.integer :postal_address_id
#   t.string :geoloc
#   t.integer :sequence
#
#   t.string :external_identifier
#   t.string :external_id_source
#
#   t.integer :transportation_route_id
#
#   t.timestamps
# end
#
# add_index :transportation_route_stops, :transportation_route_id, name: 'trans_route_stop_trans_route_idx'

class TransportationRouteStop < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :route, :class_name => "TransportationRoute", :foreign_key => "transportation_route_id"

end