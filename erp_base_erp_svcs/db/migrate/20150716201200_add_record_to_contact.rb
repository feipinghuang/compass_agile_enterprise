class AddRecordToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :contact_record_type, :string unless column_exists? :contacts, :contact_record_type
    add_column :contacts, :contact_record_id, :integer unless column_exists? :contacts, :contact_record_id

    if column_exists? :contacts, :party_id
      Contact.find_in_batches do |batch|
        batch.each do |contact|
          contact.contact_record = Party.find contact.party_id
          contact.save
        end
      end
    end

    remove_column :contacts, :party_id if column_exists? :contacts, :party_id

    add_index :contacts, [:contact_record_type, :contact_record_id], name: 'contacts_contact_record_idx' unless index_exists? :contacts, name: 'contacts_record_idx'
  end

  def down
    remove_column :contacts, :contact_record_type if column_exists? :contacts, :contact_record_type
    remove_column :contacts, :contact_record_id if column_exists? :contacts, :contact_record_id

    add_column :contacts, :party_id, :integer unless column_exists? :contacts, :party_id

    if column_exists? :contacts, :record_id

      Contact.find_in_batches do |batch|
        batch.each do |contact|
          record = contact.contact_record
          if record and record.is_a? Party
            contact.party_id = record.id
            contact.save
          end

        end
      end
    end

    remove_index :contacts, name: 'contacts_contact_record_idx' if index_exists? :contacts, name: 'contacts_contact_record_idx'
  end
end
