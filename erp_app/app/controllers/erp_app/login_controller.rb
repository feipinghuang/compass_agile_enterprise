module ErpApp
  class LoginController < ApplicationController
    layout :nil

    def index
      if session[:return_to_url]
        if session[:return_to_url].include? 'erp_app/desktop'
          @app_container = '/erp_app/desktop/'
        else
          @app_container = '/erp_app/organizer/'
        end
      else
        if params[:application] == 'desktop'
          @app_container = '/erp_app/desktop/'
        else
          @app_container = '/erp_app/organizer/'
        end
      end
    end

    def reset_password
      @token = params[:token].present? ? params[:token].strip : nil
      @user = User.load_from_reset_password_token(@token)

      if @user.blank?
        flash[:notice] = 'Invalid Reset Token'
        redirect_to action: :index
      end
    end

    def update_password
      @token = params[:token].strip
      @user = User.load_from_reset_password_token(@token)

      if @user.blank?
        render :update => {:id => "#{@uuid}_result", :view => :invalid_reset_token}
      else
        # the next line makes the password confirmation validation work
        @user.password_confirmation = params[:password_confirmation].strip
        # the next line clears the temporary token and updates the password
        if @user.change_password!(params[:password].strip)
          flash[:notice] = 'Password Reset Successfully'
          render json: {success: true}
        else
          render json: {success: false, message: @user.errors.full_messages.join('<br/>')}
        end
      end
    end

  end
end