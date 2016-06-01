class RailsDbAdminApplication

  def self.up
    if DesktopApplication.find_by_internal_identifier('rails_db_admin').nil?
      rails_db_admin_app = DesktopApplication.create(
        :description => 'RailsDbAdmin',
        :icon => 'icon-rails_db_admin',
        :internal_identifier => 'rails_db_admin'
      )

      admin_user = User.find_by_username('admin')
      admin_user.desktop_applications << rails_db_admin_app
      admin_user.save

      rails_db_admin_app.add_party_with_role(admin_user.party.dba_organization, RoleType.iid('dba_org'))
    end
  end

  def self.down
    DesktopApplication.find_by_internal_identifier('rails_db_admin').destroy
  end

end
