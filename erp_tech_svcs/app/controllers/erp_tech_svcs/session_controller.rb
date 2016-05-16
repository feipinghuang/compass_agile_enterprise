module ErpTechSvcs
  class SessionController < ActionController::Base
    def create
      login = params[:login].strip
      if login(login, params[:password])
        # log when someone logs in
        ErpTechSvcs::ErpTechSvcsAuditLog.successful_login(current_user)

        # set logout
        session[:logout_to] = params[:logout_to]

        login_to = session[:return_to_url].blank? ? params[:login_to] : session[:return_to_url]
        request.xhr? ? (render :json => {:success => true, :login_to => login_to}) : (redirect_to login_to)
      else
        message = "Login failed. Try again"
        flash[:notice] = message
        request.xhr? ? (render :json => {:success => false, :errors => {:reason => message}}) : (render :text => message)
      end
    end

    def destroy
      message = "You have logged out."
      user = current_user
      logout_to = session[:logout_to]

      # clear return_to_url
      session[:return_to_url] = nil

      logout

      # log when someone logs out
      ErpTechSvcs::ErpTechSvcsAuditLog.successful_logout(user) unless user.nil?

      if logout_to
        redirect_to logout_to, :notice => message
      else
        login_url = params[:login_url].blank? ? ErpTechSvcs::Config.login_url : params[:login_url]
        redirect_to login_url, :notice => message
      end
    end

    def keep_alive
      render :json => {:success => true, :last_activity_at => current_user.last_activity_at}
    end

    def is_alive
      if current_user
        time_since_last_activity = (Time.now - current_user.last_activity_at)

        if time_since_last_activity > (ErpApp::Config.session_redirect_after * 60)
          render :json => {alive: false}
        else
          render :json => {alive: true}
        end
      else
        render :json => {alive: false}
      end
    end

  end #SessionsController
end #ErpTechSvcs