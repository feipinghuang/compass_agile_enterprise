module Widgets
  module ResetPassword
    class Base < ErpApp::Widgets::Base

      def index
        @website = Website.find_by_host(request.host_with_port)
        @reset_password_url = params[:reset_password_url] || '/reset-password'
        @domain = @website.configurations.first.get_item(ConfigurationItemType.find_by_internal_identifier('primary_host')).options.first.value

        if params[:token].present?
          @token = params[:token].strip
          @user = User.load_from_reset_password_token(params[:token])

          if @user.blank?
            render view: :invalid_reset_token
          else
            render view: :reset_password
          end
        else
          render
        end
      end

      def update_password
        @login_url = params[:login_url] || '/login'
        @token = params[:token].present? ? params[:token].strip : nil
        @user = User.load_from_reset_password_token(@token)

        if @user.blank?
          render :update => {:id => "#{@uuid}_result", :view => :invalid_reset_token}
        else
          # the next line makes the password confirmation validation work
          @user.password_confirmation = params[:password_confirmation].strip
          # the next line clears the temporary token and updates the password
          if @user.change_password!(params[:password].strip)
            render :update => {:id => "#{@uuid}_result", :view => :reset_success}
          else
            render :update => {:id => "#{@uuid}_result", :view => :reset_password}
          end
        end
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Reset Password"
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

    end # Base
  end # ResetPassword
end # Widgets

