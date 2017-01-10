module Knitkit
  class BaseController < ::ErpApp::ApplicationController
    before_filter :set_website
    before_filter :set_login_path, :set_active_publication, :load_sections, :set_section, :except => [:view_current_publication, :website_preview]
    acts_as_themed_controller

    layout 'knitkit/base', :except => :website_preview

    def website_preview
      website_section = website.website_sections.where(title: website.name).first if website.present?
      @website_section_contents = website_section ? website_section.website_section_contents.order("position") : []
      render :layout => false
    end

    def website
      @website
    end

    def view_current_publication
      session[:website_version].delete_if{|item| item[:website_id] == @website.id}
      redirect_to request.env["HTTP_REFERER"]
    end

    protected
    def set_website
      @website = Website.find_by_host(request.host_with_port)
    end

    def load_sections
      @website_sections = @website.website_sections.positioned
    end

    def set_section
      unless params[:section_id].nil?
        @website_section = WebsiteSection.find(params[:section_id])
        @website_section = @website_section.root if @website_section.is_document_section? # check security on root document section
        if @website_section.protected_with_capability?(:view)
          if !current_user and @website_section.path != @login_path
            session[:return_to_url] = @website_section.path
            redirect_to @login_path
          elsif current_user and !current_user.has_capability?(:view, @website_section)
            redirect_to Knitkit::Config.unauthorized_url
          end
        end
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def set_login_path
      @login_path = @website.configurations.first.get_configuration_item(ConfigurationItemType.find_by_internal_identifier('login_url')).options.first.value
    end

    def set_active_publication
      @active_publication = @website.active_publication
      if !session[:website_version].blank? && !session[:website_version].empty?
        site_version_hash = session[:website_version].find{|item| item[:website_id] == @website.id}
        unless site_version_hash.nil?
          @active_publication = @website.published_websites.where('version = ?', site_version_hash[:version].to_f).first
        end
      end
    end
  end
end
