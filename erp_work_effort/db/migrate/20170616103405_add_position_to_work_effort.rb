class AddPositionToWorkEffort < ActiveRecord::Migration
  def change
    add_column :work_efforts, :position, :integer
    WorkEffort.order(:start_at).each.with_index(1) do |work_effort, index|
      work_effort.update_column :position, index
    end
  end
end
