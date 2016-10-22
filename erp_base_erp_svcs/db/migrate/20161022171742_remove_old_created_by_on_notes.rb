class RemoveOldCreatedByOnNotes < ActiveRecord::Migration
  def up
    if column_exists? :notes, :created_by_id
      ActiveRecord::Base.connection.execute "update notes set created_by_party_id = created_by_id where created_by_party_id is null;"

      remove_column :notes, :created_by_id
    end
  end

  def down
    if column_exists? :notes, :created_by_id
      add_column :notes, :created_by_id, :integer
    end
  end
end
