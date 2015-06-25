class ErpAppSetup

  def self.up

    #######################################
    # contact purposes
    #######################################
    [
        {:description => 'Default', :internal_identifier => 'default'},
        {:description => 'Home', :internal_identifier => 'home'},
        {:description => 'Work', :internal_identifier => 'work'},
        {:description => 'Billing', :internal_identifier => 'billing'},
        {:description => 'Temporary', :internal_identifier => 'temporary'},
        {:description => 'Tax Reporting', :internal_identifier => 'tax_reporting'},
        {:description => 'Recruiting', :internal_identifier => 'recruiting'},
        {:description => 'Employment Offer', :internal_identifier => 'employment_offer'},
        {:description => 'Business', :internal_identifier => 'business'},
        {:description => 'Personal', :internal_identifier => 'personal'},
        {:description => 'Fax', :internal_identifier => 'fax'},
        {:description => 'Mobile', :internal_identifier => 'mobile'},
        {:description => 'Emergency', :internal_identifier => 'emergency'},
        {:description => 'Shipping', :internal_identifier => 'shipping'},
        {:description => 'Other', :internal_identifier => 'other'},
    ].each do |item|
      contact_purpose = ContactPurpose.find_by_internal_identifier(item[:internal_identifier])
      ContactPurpose.create(:description => item[:description], :internal_identifier => item[:internal_identifier]) if contact_purpose.nil?
    end

    #######################################
    # security roles
    #######################################
    admin_security_role = SecurityRole.create(:description => 'Admin', :internal_identifier => 'admin')
    employee_security_role = SecurityRole.create(:description => 'Employee', :internal_identifier => 'employee')

    admin_security_role.add_capability('create', 'User')
    admin_security_role.add_capability('delete', 'User')

    admin_security_role.add_capability('create', 'Note')
    employee_security_role.add_capability('create', 'Note')

    admin_security_role.add_capability('view', 'Note')
    employee_security_role.add_capability('view', 'Note')

    admin_security_role.add_capability('edit', 'Note')
    employee_security_role.add_capability('edit', 'Note')

    admin_security_role.add_capability('delete', 'Note')

    #######################################
    # Role Types
    #######################################

    RoleType.create(description: 'Customer', internal_identifier: 'customer')

    #######################################
    # desktop setup
    #######################################

    #create preference options
    #yes no options
    PreferenceOption.create(:description => 'Yes', :internal_identifier => 'yes', :value => 'yes')
    PreferenceOption.create(:description => 'No', :internal_identifier => 'no', :value => 'no')

    #create application and assign widgets
    user_mgr_app = DesktopApplication.create(
        :description => 'User Management',
        :icon => 'icon-user',
        :internal_identifier => 'user_management'
    )

    #######################################
    # organizer setup
    #######################################

    #create application
    crm_app = Application.create(
        :description => 'CRM',
        :icon => 'icon-user',
        :internal_identifier => 'crm'
    )

    #######################################
    # Setup party roles and parties
    #######################################

    # Create Doing Business As Organization role
    dba_role_type = RoleType.find_or_create('dba_org', 'Doing Business As Organization')
    representative_role_type = RoleType.find_or_create('representative', 'Representative')
    representative_to_dba_reln_type = RelationshipType.find_or_create(dba_role_type, representative_role_type)

    # Doing Business As Organization
    compass_ae_org = Organization.create(description: 'CompassAE')
    compass_ae_org_party = compass_ae_org.party
    compass_ae_org_party.add_role_type(dba_role_type)

    # Admins
    admin = Individual.create(:current_first_name => 'Admin', :current_last_name => 'Istrator', :gender => 'm')
    admin_party = admin.party

    admin_party.create_relationship("Member of CompassAE", compass_ae_org_party.id, representative_to_dba_reln_type)

    #######################################
    # users
    #######################################
    admin_user = User.create(
        :username => "admin",
        :email => "admin@portablemind.com"
    )
    admin_user.password = 'password'
    admin_user.password_confirmation = 'password'
	admin_user.save
    admin_user.party = admin_party
    admin_user.activate!
    admin_user.save
    admin_user.add_security_role('admin')
    admin_user.save

    admin_user.apps << crm_app
    admin_user.desktop_applications << user_mgr_app
    admin_user.save

    ########################################
    # Create applications
    ########################################
    app = DesktopApplication.create(
        :description => 'Audit Log Viewer',
        :icon => 'icon-history',
        :internal_identifier => 'audit_log_viewer'
    )

    admin_user.desktop_applications << app
    admin_user.save

    app = DesktopApplication.create(
        :description => 'File Manager',
        :icon => 'icon-folders',
        :internal_identifier => 'file_manager'
    )

    admin_user.desktop_applications << app
    admin_user.save

    app = DesktopApplication.create(
        :description => 'Job Tracker',
        :icon => 'icon-calendar',
        :internal_identifier => 'job_tracker'
    )

    admin_user.desktop_applications << app
    admin_user.save

    app = DesktopApplication.create(
        :description => 'Security Management',
        :icon => 'icon-key',
        :internal_identifier => 'security_management',
    )

    admin_user.desktop_applications << app
    admin_user.save

    ########################################
    # Create Job Trackers
    ########################################
    JobTracker.create(
        :job_name => 'Delete Expired Sessions',
        :job_klass => 'ErpTechSvcs::Sessions::DeleteExpiredSessionsJob'
    )
  end

  def self.down
    #remove data here
  end

end
