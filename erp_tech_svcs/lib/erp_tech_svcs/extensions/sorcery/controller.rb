Sorcery::Controller::InstanceMethods.class_eval do

  # To be used as before_filter.
  # First it will look for an auth token from a mobile app and try to validate it
  # Then it will follow the normal Sorcery path.
  # Will trigger auto-login attempts via the call to logged_in?
  # If all attempts to auto-login fail, the failure callback will be called.
  def require_login
    if params[:current_user_id].present? and params[:auth_token].present?
      @current_user = User.find(params[:current_user_id])
      unless @current_user and @current_user.auth_token == params[:auth_token]
        Rails.logger.info("*************************************************************************************")
        Rails.logger.info("#{Time.now} - Invalid AuthToken for user")
        Rails.logger.info("AuthToken: #{params[:auth_token]} UserId: #{params[:current_user_id]}")
        Rails.logger.info("UserId: #{params[:user_id]}")
        Rails.logger.info("*************************************************************************************")

        render :json => {:success => false, :invalid_auth_token => true, :message => 'Connection is no longer valid'}
        return false
      end
    else
      unless logged_in?
        self.send(Sorcery::Controller::Config.not_authenticated_action)
      end
    end
  end

end
