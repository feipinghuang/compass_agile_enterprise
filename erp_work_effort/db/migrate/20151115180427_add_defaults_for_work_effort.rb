class AddDefaultsForWorkEffort < ActiveRecord::Migration
  def up
    change_column :work_efforts, :percent_done, :integer, default: 0
    change_column :work_efforts, :duration, :integer, default: 0
    change_column :work_efforts, :duration_unit, :string, default: 'd'
    change_column :work_efforts, :effort, :integer, default: 0
    change_column :work_efforts, :duration_unit, :string, default: 'd'

    WorkEffort.all.each do |work_effort|
      # clean data
      if work_effort.percent_done.blank?
        work_effort.percent_done = 0
      end

      if work_effort.duration.blank?
        work_effort.duration = 0
        work_effort.duration_unit = 'd'
      end

      if work_effort.effort.blank?
        work_effort.effort = 0
        work_effort.effort_unit = 'd'
      end

      work_effort.save!
    end
  end

  def down
    change_column :work_efforts, :percent_done, :integer
    change_column :work_efforts, :duration, :integer
    change_column :work_efforts, :duration_unit, :string
    change_column :work_efforts, :effort, :integer
    change_column :work_efforts, :duration_unit, :string
  end
end
