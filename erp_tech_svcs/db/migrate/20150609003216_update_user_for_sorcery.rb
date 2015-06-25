class UpdateUserForSorcery < ActiveRecord::Migration
  def up
	add_column :users, :unlock_token, :string, :default => nil
	add_column :users, :last_login_from_ip_address, :string, :default => nil
  end

  def down
	remove_column :users, :unlock_token
	remove_column :users, :last_login_from_ip_address
  end
end
