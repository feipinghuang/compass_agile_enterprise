module Widgets
  module Search
    class Base < ErpApp::Widgets::Base
      include ActionDispatch::Routing::UrlFor
      include Rails.application.routes.url_helpers
      include WillPaginate::ActionView

      def index
        @section_unique_name = params[:section_to_search]
        @content_type = params[:content_type]
        @results_permalink = params[:results_permalink]
        @per_page = params[:per_page] || 10
        @redirect_results = params[:redirect_results]
        @inline = !@results_permalink.blank?
        @results = nil

        if params[:query].present?
          query = params[:query].strip
          page = params[:page] || 1

          @results = self.perform_search(query, @content_type, @section_unique_name, @per_page, page)
        end

        render
      end

      def search
        @query = params[:search_query].strip
        @content_type = params[:content_type]
        @section_unique_name = params[:section_unique_name]
        @per_page = params[:per_page]
        page = params[:page] || 1

        @results = self.perform_search(@query, @content_type, @section_unique_name, @per_page, page)

        if request.xhr?
          render :update => {:id => "#{@uuid}_result", :view => :show}
        else
          render :view => :show
        end
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Search"
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end

        def base_layout
          begin
            file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
            IO.read(file)
          rescue
            return nil
          end
        end
      end

      protected

      def perform_search(query, content_type, section_unique_name, per_page, page)
        website = Website.find_by_host(request.host_with_port)

        options = {
            :website_id => website.id,
            :section_unique_name => section_unique_name,
            :query => query,
            :content_type => content_type,
            :page => page,
            :per_page => per_page
        }

        Content.do_search(options)
      end

    end
  end
end

