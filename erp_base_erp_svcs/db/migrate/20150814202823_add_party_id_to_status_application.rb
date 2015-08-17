class AddPartyIdToStatusApplication < ActiveRecord::Migration
  def up
    add_column :status_applications, :party_id, :integer unless column_exists? :status_applications, :party_id
    add_index :status_applications, :party_id, name: 'status_application_party_idx' unless index_exists? :status_applications, 'status_application_party_idx'
  end

  def down
    remove_column :status_applications, :party_id if column_exists? :status_applications, :party_id
  end
end
