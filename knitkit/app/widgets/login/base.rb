module Widgets
  module Login
    class Base < ErpApp::Widgets::Base

      def index
        @logout_to  = params[:logout_to]
        @login_to   = (session[:return_to_url] or params[:login_to])
        @signup_url = params[:signup_url]
        @reset_password_url = params[:reset_password_url]
        @message = flash[:notice]
    
        render
      end
      
      def website_builder
        if original_action == :index
          @header = false
          @logout_to  = params[:logout_to]
          @login_to   = (session[:return_to_url] or params[:login_to])
          @signup_url = params[:signup_url]
          @reset_password_url = params[:reset_password_url]
        elsif original_action == :login_header
          @header = true
          @login_url     = params[:login_url]
          @signup_url    = params[:signup_url]
        end
        render
      end

      def login_header
        @login_url     = params[:login_url]
        @signup_url    = params[:signup_url]
        @authenticated = logged_in?
        @user = current_user if logged_in?
        
        render
      end

      def reset_password
        @login_url     = params[:login_url]
        
        render
      end


      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end
        
      class << self
        def title
          "Login"
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end
        
        def base_layout
          begin
            file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
            IO.read(file)
          rescue
            return nil
          end
        end
      end
    end
  end
end

