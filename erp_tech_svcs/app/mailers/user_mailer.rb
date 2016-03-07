class UserMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def activation_needed_email(user, dba_organization=nil)
    @user = user
    @url  = "#{get_domain(user.instance_attributes[:domain])}/users/activate/#{user.activation_token}"
    @url << "?login_url=#{@user.instance_attributes[:login_url]}" unless @user.instance_attributes[:login_url].nil?

    @temp_password = @user.instance_attributes[:temp_password] unless @user.instance_attributes[:temp_password].nil?
    
    ::ActionMailer::Base.load_configuration(dba_organization)
    mail(:to => user.email, :subject => "An account has been created and needs activation")
  end

  def reset_password_email(user, dba_organization=nil)
    @user = user
    @reset_password_token = @user.reset_password_token

    @url  = "#{get_domain(user.instance_attributes[:domain])}#{@user.instance_attributes[:reset_password_url]}?token=#{@reset_password_token}"
    
    ::ActionMailer::Base.load_configuration(dba_organization) if dba_organization.present?
    mail(:to => user.email, :subject => "Your password has been reset")
  end

  def get_domain(domain)
    domain = domain || ErpTechSvcs::Config.installation_domain

   "#{ErpTechSvcs::Config.file_protocol}://#{domain}"
  end
end