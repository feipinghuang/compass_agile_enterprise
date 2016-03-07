class CrmMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def send_message(to_email, subject, message, dba_organization=nil)
    @message = message
    
    ::ActionMailer::Base.load_configuration(dba_organization) if dba_organization.present?
    mail(:to => to_email, :subject => subject)
  end

end