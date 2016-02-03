UserMailer.class_eval do
  acts_as_themed_mailer

  def activation_needed_email(user)
    # add theme paths if a website is present
    if user.instance_attributes[:website_id]
      add_theme_view_paths(Website.find(user.instance_attributes[:website_id]))
    end

    @user = user
    @url  = "#{get_domain(user.instance_attributes[:domain])}/users/activate/#{user.activation_token}"
    @url << "?login_url=#{@user.instance_attributes[:login_url]}" unless @user.instance_attributes[:login_url].nil?

    @temp_password = @user.instance_attributes[:temp_password] unless @user.instance_attributes[:temp_password].nil?

    mail(:to => user.email, :subject => "An account has been created and needs activation")
  end

  def reset_password_email(user)
    # add theme paths if a website is present
    if user.instance_attributes[:website_id]
      add_theme_view_paths(Website.find(user.instance_attributes[:website_id]))
    end

    @user = user
    @reset_password_token = @user.reset_password_token

    @url  = "#{get_domain(user.instance_attributes[:domain])}#{@user.instance_attributes[:reset_password_url]}?token=#{@reset_password_token}"
    mail(:to => user.email, :subject => "Your password has been reset")
  end
end