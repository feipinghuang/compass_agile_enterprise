class AddApplicationsToDbaOrg

  def self.up
    admin = User.find_by_username('admin')
    if admin
      dba_org = admin.party.dba_organization
      role_type = RoleType.iid('dba_org')

      Application.all.each do |application|
        unless application.find_party_with_role(role_type) == dba_org
          application.add_party_with_role(dba_org, role_type)
        end
      end

    end
  end

  def self.down
    admin = User.find_by_username('admin')
    if admin
      dba_org = admin.party.dba_organization
      role_type = RoleType.iid('dba_org')

      Application.all.each do |application|
        application.remove_party_with_role(dba_org, role_type)
      end
    end

  end

end
