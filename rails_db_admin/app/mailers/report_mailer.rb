class ReportMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def email_report(to_email, cc_email, file_attachments, subject, message, dba_organization=nil)
    @message = message
    @subject = subject

    file_attachments.each do |file_attachment|
      attachments[file_attachment[:name]] = file_attachment[:data]
    end

	::ActionMailer::Base.load_configuration(dba_organization) if dba_organization.present?
    mail(:to => to_email, :subject => subject, :cc => cc_email)
  end

end