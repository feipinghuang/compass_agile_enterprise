# create_table :auth_tokens do |t|
#   t.references :user
#   t.string :token
#   t.datetime :expires_at
#
#   t.timestamps
# end
#
# add_index :auth_tokens, :user_id, name: 'auth_tokens_user_idx'
# add_index :auth_tokens, :token, name: 'auth_tokens_token_idx'
# add_index :auth_tokens, :expires_at, name: 'auth_tokens_expires_at_idx'

class AuthToken < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :user

  def self.expired
    where(AuthToken.arel_table[:expires_at].lt(Time.now))
  end

  def self.valid
    where(AuthToken.arel_table[:expires_at].gteq(Time.now))
  end

  def self.by_request_ip(request_ip)
    where(AuthToken.arel_table[:request_ip].eq(request_ip))
  end

  def self.generate(request_ip, expires_at)
    self.create(
      token: SecureRandom.uuid,
      request_ip: request_ip,
      expires_at: expires_at
    )
  end
end
