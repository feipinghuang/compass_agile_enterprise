class CrmMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def send_message(to_email, subject, message, dba_organization=nil)
    @message = message
    
    mail(:to => to_email, :subject => subject)
  end

end