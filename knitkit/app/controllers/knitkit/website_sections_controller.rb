module Knitkit
  class WebsiteSectionsController < BaseController

    def index
      @contents = Component.find_published_by_section(@active_publication, @website_section)
      layout = @website_section.get_published_layout(@active_publication)

      if params[:is_mobile]
        layout.blank? ? (render :layout => false) : (render :inline => layout, :layout => false)
      elsif layout.blank?
        @website_section.render_base_layout? ? (render) : (render :layout => false)
      else
        @website_section.render_base_layout? ? (render :inline => layout, :layout => 'knitkit/base') : (render :inline => layout)
      end

    end

  end
end
