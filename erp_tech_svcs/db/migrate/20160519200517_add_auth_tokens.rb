class AddAuthTokens < ActiveRecord::Migration
  def up
    unless table_exists? :auth_tokens
      create_table :auth_tokens do |t|
        t.references :user
        t.string :token
        t.string :request_ip
        t.datetime :expires_at

        t.timestamps
      end

      add_index :auth_tokens, :user_id, name: 'auth_tokens_user_idx'
      add_index :auth_tokens, :token, name: 'auth_tokens_token_idx'
      add_index :auth_tokens, :expires_at, name: 'auth_tokens_expires_at_idx'
      add_index :auth_tokens, :request_ip, name: 'auth_tokens_request_ip_idx'

      #  move any current auth tokens from the users table if they are there
      sql = 'insert into auth_tokens (user_id, token, expires_at, created_at, updated_at)
      	     select id, auth_token, auth_token_expires_at, current_timestamp, current_timestamp from users'

      execute sql

      remove_column :users, :auth_token
      remove_column :users, :auth_token_expires_at
    end
  end

  def down
    if table_exists? :auth_tokens
      drop_table :auth_tokens

      add_column :users, :auth_token, :string
      add_column :users, :auth_token_expires_at, :datetime
    end
  end
end
