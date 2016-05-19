module ErpApp
  class WidgetProxyController < ErpApp::ApplicationController

    attr_accessor :performed_redirect

    protect_from_forgery :except => :clear

    def index
      @widget_name = params[:widget_name]
      @widget_action = params[:widget_action]
      @uuid = params[:uuid]

      #get widget params
      widget_params = nil
      widget_params = JSON.parse(params[:widget_params]) unless params[:widget_params].blank?

      widget_obj = "::Widgets::#{@widget_name.camelize}::Base".constantize.new(self, @widget_name, @widget_action, @uuid, widget_params)

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

    def clear
      unless params[:uuids].blank?
        params[:uuids].split(',').each do |uuid|
          if session[:widgets] and session[:widgets][uuid]
            session[:widgets].delete(uuid)
          end
        end
      end

      render json: {success: true}
    end

  end # WidgetProxyController
end # ErpApp
