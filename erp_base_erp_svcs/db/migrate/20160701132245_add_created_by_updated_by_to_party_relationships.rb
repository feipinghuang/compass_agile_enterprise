class AddCreatedByUpdatedByToPartyRelationships < ActiveRecord::Migration
  def up
  	unless column_exists? :party_relationships, :created_by_party_id
      add_column :party_relationships, :created_by_party_id, :integer

      add_index :party_relationships, :created_by_party_id, name: "party_relationships_created_by_pty_idx"
    end

    unless column_exists? :party_relationships, :updated_by_party_id
      add_column :party_relationships, :updated_by_party_id, :integer

      add_index :party_relationships, :updated_by_party_id, name: "party_relationships_updated_by_pty_idx"
    end
  end

  def down
  	if column_exists? :party_relationships, :created_by_party_id
      remove_column :party_relationships, :created_by_party_id
    end

    if column_exists? :party_relationships, :updated_by_party_id
      remove_column :party_relationships, :updated_by_party_id
    end
  end
end
