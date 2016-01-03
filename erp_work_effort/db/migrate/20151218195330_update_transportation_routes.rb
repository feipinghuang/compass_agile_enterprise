class UpdateTransportationRoutes < ActiveRecord::Migration
  def up
    unless index_exists? :transportation_route_stops, 'trans_route_stop_trans_route_idx'
      add_index :transportation_route_stops, :transportation_route_id, name: 'trans_route_stop_trans_route_idx'
    end

    unless column_exists? :transportation_routes, :billable
      add_column :transportation_routes, :billable, :boolean, default: false
      add_column :transportation_routes, :manual_entry, :boolean, default: true
    end

    unless index_exists? :transportation_route_segments, 'trans_route_seg_trans_route_id_idx'
      add_index :transportation_route_segments, :transportation_route_id, name: 'trans_route_seg_trans_route_id_idx'
      add_index :transportation_route_segments, :from_transportation_route_stop_id, name: 'trans_route_seg_from_trans_stop_idx'
      add_index :transportation_route_segments, :to_transportation_route_stop_id, name: 'trans_route_seg_to_trans_stop_idx'
    end

    unless column_exists? :transportation_route_segments, :miles_traveled
      rename_column :transportation_route_segments, :end_milage, :end_mileage
      change_column :transportation_route_segments, :end_mileage, :decimal, :precision => 8, :scale => 1

      change_column :transportation_route_segments, :start_mileage, :decimal, :precision => 8, :scale => 1
      add_column :transportation_route_segments, :miles_traveled, :decimal, :precision => 8, :scale => 1

      rename_column :transportation_route_segments, :estmated_arrival, :estimated_arrival
    end
  end

  def down
    if index_exists? :transportation_route_stops, :transportation_route_id, name: 'trans_route_stop_trans_route_idx'
      remove_index :transportation_route_stops, name: 'trans_route_stop_trans_route_idx'
    end

    if column_exists? :transportation_routes, :billable
      remove_column :transportation_routes, :billable
      remove_column :transportation_routes, :manual_entry
    end

    if index_exists? :transportation_route_segments, :transportation_route_id, name: 'trans_route_seg_trans_route_id_idx'
      remove_index :transportation_route_segments, name: 'trans_route_seg_trans_route_id_idx'
      remove_index :transportation_route_segments, name: 'trans_route_seg_from_trans_stop_idx'
      remove_index :transportation_route_segments, name: 'trans_route_seg_to_trans_stop_idx'
    end

    if column_exists? :transportation_route_segments, :miles_traveled
      rename_column :transportation_route_segments, :end_mileage, :end_milage
      change_column :transportation_route_segments, :end_milage, :integer

      change_column :transportation_route_segments, :start_mileage, :integer
      remove_column :transportation_route_segments, :miles_traveled

      rename_column :transportation_route_segments, :estimated_arrival, :estmated_arrival
    end

  end
end