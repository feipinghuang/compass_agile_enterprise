API::V1::BaseController.class_eval do

  before_filter :set_website_dba_organization

  def set_website_dba_organization
    website = Website.find_by_host(request.host_with_port)

    if website
      @website_dba_organization = website.dba_organization
    end
  end

  protected

  def check_dba_organization
    if current_user
      @dba_organization = current_user.party.dba_organization
    elsif @website_dba_organization
      @dba_organization = @website_dba_organization
    end

    unless @dba_organization
      self.send(Sorcery::Controller::Config.not_authenticated_action)
    end
  end

end
