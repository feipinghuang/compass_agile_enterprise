class WebsiteInquiryMailer < ActionMailer::Base
  acts_as_themed_mailer

  default :from => ErpTechSvcs::Config.email_notifications_from

  def inquiry(website_inquiry)
    # add theme paths if a website is present
    if website_inquiry.website
      add_theme_view_paths(website_inquiry.website)
    end

    subject = "#{website_inquiry.website.title} Inquiry"
    @website_inquiry = website_inquiry

    mail(:to => website_inquiry.website.configurations.first.get_item(ConfigurationItemType.find_by_internal_identifier('contact_us_email_address')).options.first.value,
         :subject => subject,
         :content_type => 'text/html'
    )
  end
end

