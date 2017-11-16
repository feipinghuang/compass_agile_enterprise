ErpApp::WidgetProxyController.class_eval do
  attr_accessor :performed_redirect
  before_filter :set_website

  def index
    @widget_name = ActionController::Base.helpers.sanitize(params[:widget_name]).to_param
    @widget_action = params[:widget_action]
    @uuid = params[:uuid]

    #get widget params
    widget_params = nil
    widget_params = JSON.parse(params[:widget_params]) unless params[:widget_params].blank?

    widget_obj = "::Widgets::#{@widget_name.camelize}::Base".constantize.new(self, @widget_name, @widget_action, @uuid, widget_params, @website)

    result = widget_obj.process(@widget_action)

    #if there was no result just return
    return if result.nil?

    if result.is_a?(Hash)
      if !result[:send_file] and !result[:send_data] and !result[:redirect_to]
        render result
      end
    else
      render :inline => result
    end

  end

  protected
  #setting website to pass to widgets
  def set_website
    @website = Website.find_by_host(request.host_with_port)
  end

end
