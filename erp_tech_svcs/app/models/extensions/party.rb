Party.class_eval do
  has_security_roles
  has_many :users, :dependent => :destroy

  has_file_assets

  # Helper method as most parties will have only one user
  def user
    users.first
  end
end
