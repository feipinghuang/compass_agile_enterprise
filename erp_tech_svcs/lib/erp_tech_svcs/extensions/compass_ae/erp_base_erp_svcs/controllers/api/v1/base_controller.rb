Api::V1::BaseController.class_eval do

  before_filter :require_login, except: :generate_auth_token

  def generate_auth_token
    if params[:username] && params[:password] && (user = login(params[:username].strip, params[:password].strip))
      user.generate_auth_token!

      # log when someone logs in
      ErpTechSvcs::ErpTechSvcsAuditLog.successful_login(user)

      render :json => {success: true, user_id: user.id, auth_token: user.auth_token, auth_token_expires_at: user.auth_token_expires_at}
    else
      render :json => {success: false}
    end
  end

end # Api
