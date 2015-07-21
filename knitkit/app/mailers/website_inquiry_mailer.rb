class WebsiteInquiryMailer < ActionMailer::Base
  default :from => ErpTechSvcs::Config.email_notifications_from

  def inquiry(website_inquiry)
    subject = "#{website_inquiry.website.title} Inquiry"
    @website_inquiry = website_inquiry

    mail(:to => website_inquiry.website.configurations.first.get_item(ConfigurationItemType.find_by_internal_identifier('contact_us_email_address')).options.first.value,
         :subject => subject,
         :content_type => 'text/html'
    )
  end
end

