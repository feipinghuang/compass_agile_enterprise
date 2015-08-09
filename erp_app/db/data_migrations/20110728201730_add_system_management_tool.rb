# This migration comes from erp_app (originally 20110728201730)
class AddSystemManagementTool

  def self.up
    #create application and assign widgets
    system_mgmt_tool = DesktopApplication.find_by_internal_identifier('system_management')

    if system_mgmt_tool.nil?
      system_mgmt_tool = DesktopApplication.create(
          :description => 'System Management',
          :icon => 'icon-settings',
          :internal_identifier => 'system_management'
      )
    end

    admin_user = User.find_by_username('admin')
    unless admin_user.desktop_applications.where("internal_identifier = 'system_management'").count > 0
      admin_user.desktop_applications << system_mgmt_tool
      admin_user.save
    end
  end

  def self.down
    DesktopApplication.iid('system_management').destroy
  end

end
