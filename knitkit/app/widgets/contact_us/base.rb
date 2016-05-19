module Widgets
  module ContactUs
    class Base < ErpApp::Widgets::Base
      include ActionView::Helpers::SanitizeHelper

      def index
        render
      end

      def new
        website = Website.find_by_host(request.host_with_port)

        website_inquiry = WebsiteInquiry.new
        website_inquiry.created_by = current_user unless current_user.nil?
        website_inquiry.website = website
        website_inquiry.first_name = params[:first_name].strip
        website_inquiry.last_name = params[:last_name].strip
        website_inquiry.message = params[:message].strip
        website_inquiry.email = params[:email].strip

        if website_inquiry.save
          if website.email_inquiries?
            WebsiteInquiryMailer.inquiry(website_inquiry, website.dba_organization).deliver
          end
          render :update => {:id => "#{@uuid}_result", :view => :success}

        else
          @errors = @website_inquiry.errors.full_messages
          render :update => {:id => "#{@uuid}_result", :view => :error}

        end
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Contact Us"
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end

        def base_layout
          begin
            file = File.join(File.dirname(__FILE__), "/views/layouts/base.html.erb")
            IO.read(file)
          rescue
            return nil
          end
        end
      end

    end #Base
  end #ContactUs
end #Widgets
