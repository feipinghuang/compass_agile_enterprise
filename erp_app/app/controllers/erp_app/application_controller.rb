module ErpApp
	class ApplicationController < ActionController::Base
    protect_from_forgery

    protected

    def not_authenticated
      # if they requested the desktop or organizer store it so we can pre-select it on the login page	
      if request.fullpath == '/erp_app/desktop'
        session[:app_container] = :desktop
      elsif request.fullpath == ('/erp_app/organizer' || '/erp_app/csr')
      	session[:app_container] = :organizer
      end

      redirect_to '/erp_app/login', :notice => "Please login first."
    end
    
	end
end
