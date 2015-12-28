# create_table :transportation_route_segments do |t|
#
#   t.string :internal_identifier
#   t.string :description
#   t.string :comments
#
#   t.string :external_identifier
#   t.string :external_id_source
#
#   t.integer :sequence
#   t.datetime :estimated_start
#   t.datetime :estimated_arrival
#   t.datetime :actual_start
#   t.datetime :actual_arrival
#   t.decimal :start_mileage, :precision => 8, :scale => 1
#   t.decimal :end_mileage, :precision => 8, :scale => 1
#   t.integer :fuel_used
#   t.decimal :miles_traveled, :precision => 8, :scale => 1
#
#   t.integer :transportation_route_id
#   t.integer :from_transportation_route_stop_id
#   t.integer :to_transportation_route_stop_id
#
#   t.timestamps
# end
#
# add_index :transportation_route_segments, :transportation_route_id, name: 'trans_route_seg_trans_route_id_idx'
# add_index :transportation_route_segments, :from_transportation_route_stop_id, name: 'trans_route_seg_from_trans_stop_idx'
# add_index :transportation_route_segments, :to_transportation_route_stop_id, name: 'trans_route_seg_to_trans_stop_idx'
#

class TransportationRouteSegment < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :route, :class_name => "TransportationRoute", :foreign_key => "transportation_route_id"

  belongs_to :from_stop, :class_name => "TransportationRouteStop", :foreign_key => "from_transportation_route_stop_id"
  belongs_to :to_stop, :class_name => "TransportationRouteStop", :foreign_key => "to_transportation_route_stop_id"

  # Calculates miles traveled for this Transportation Route Segment
  #
  def calculate_miles_traveled!

  end

  def to_data_hash
    to_hash(only: [:id, :internal_identifier, :description,
                   :comments,
                   :actual_start,
                   :actual_arrival,
                   :miles_traveled,
                   :created_at, :updated_at])


  end

end