class AddKnitkitApplication

  def self.up
    if DesktopApplication.find_by_internal_identifier('knitkit').nil?
      app = DesktopApplication.create(
        :description => 'KnitKit',
        :icon => 'icon-palette',
        :internal_identifier => 'knitkit'
      )

      admin_user = User.find_by_username('admin')
      admin_user.desktop_applications << app
      admin_user.save

      app.add_party_with_role(admin_user.party.dba_organization, RoleType.iid('dba_org'))
    end
  end

  def self.down
    DesktopApplication.find_by_internal_identifier('knitkit').destroy
  end

end
