class AddCreatedByUpdatedBy < ActiveRecord::Migration
  def up
    %w{candidate_submissions
       experiences
       party_skills
       position_fulfillments
       position_types
       positions
       projects
       shifts
       staffing_positions
       work_effort_party_assignments
       work_efforts
       time_entries
       transportation_routes
       transportation_route_segments
       wc_codes}.each do |table|

      unless column_exists? table.to_sym, :created_by_party_id
        add_column table.to_sym, :created_by_party_id, :integer

        add_index table.to_sym, :created_by_party_id, name: "#{table}_created_by_pty_idx"
      end

      unless column_exists? table.to_sym, :updated_by_party_id
        add_column table.to_sym, :updated_by_party_id, :integer

        add_index table.to_sym, :updated_by_party_id, name: "#{table}_updated_by_pty_idx"
      end

    end

  end

  def down
    %w{candidate_submissions
       experiences
       party_skills
       position_fulfillments
       position_types
       positions
       projects
       shifts
       staffing_positions
       work_effort_party_assignments
       work_efforts
       time_entries
       transportation_routes
       transportation_route_segments
       wc_codes}.each do |table|

      if column_exists? table.to_sym, :created_by_party_id
        remove_column table.to_sym, :created_by_party_id
      end

      if column_exists? table.to_sym, :updated_by_party_id
        remove_column table.to_sym, :updated_by_party_id
      end
    end

  end

end
