ErpTechSvcs::SessionController.class_eval do
  def create
    login = params[:login].strip
    if login(login, params[:password])
      login_to = session[:return_to_url].blank? ? params[:login_to] : session[:return_to_url]

      if login_to.include?('desktop') && current_user.desktop_applications.count == 0
        message = "Access Denied"
        logout
        flash[:notice] = message
        request.xhr? ? (render :json => {:success => false, :errors => {:reason => message}}) : (render :text => message)
      else
        # log when someone logs in
        audit_log_service = ErpTechSvcs::Services::AuditLog.new(current_user)
        audit_log_service.successful_login

        # set logout
        session[:logout_to] = params[:logout_to]

        request.xhr? ? (render :json => {:success => true, :login_to => login_to}) : (redirect_to login_to)
      end
    else
      message = "Login failed. Try again"
      flash[:notice] = message
      request.xhr? ? (render :json => {:success => false, :errors => {:reason => message}}) : (render :text => message)
    end
  end
end
