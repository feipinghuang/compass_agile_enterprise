class UpdateUserForSorcery < ActiveRecord::Migration
  def up
    add_column :users, :unlock_token, :string, :default => nil unless column_exists? :users, :unlock_token
    add_column :users, :last_login_from_ip_address, :string, :default => nil unless column_exists? :users, :last_login_from_ip_address
  end

  def down
    remove_column :users, :unlock_token
    remove_column :users, :last_login_from_ip_address
  end
end
