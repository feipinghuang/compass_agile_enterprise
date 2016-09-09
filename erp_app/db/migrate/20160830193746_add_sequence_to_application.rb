class AddSequenceToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :sequence, :integer, :default => 0 unless column_exists?(:applications, :sequence)
  end
end
