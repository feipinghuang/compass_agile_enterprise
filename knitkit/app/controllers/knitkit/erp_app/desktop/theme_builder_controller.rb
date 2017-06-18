module Knitkit
  module ErpApp
    module Desktop
      class ThemeBuilderController < Knitkit::ErpApp::Desktop::AppController
        before_filter :set_website, except: :update_layout

        acts_as_themed_controller website_builder: true

        skip_before_filter :add_theme_view_paths, only: [:update_layout]
        
        def website
          @website
        end
        
        def update_layout
          begin
            theme = Theme.find(params[:id])
            header = JSON.parse(params[:header]) rescue {}
            footer = JSON.parse(params[:footer]) rescue {}
            
            result = theme.update_base_layout!({
                                                header: header,
                                                footer: footer
                                              })
            render json: {
                     success: true,
                     result: {
                       header: result[:header],
                       footer: result[:footer]
                     }
                   }
          rescue Exception => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")
            
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier
          end
        end

        def render_theme_component
          template_type = params[:template_type]
          @website_builder = true
          theme = @website.themes.first
          @website_sections = @website.website_sections.positioned
          builder_html = theme.meta_data[template_type]['builder_html']
          
          render inline: builder_html, layout: 'knitkit/base'
        end

        protected
        
        def set_website
          @website = Website.find(params[:website_id])
        end
        
      end # ThemeBuilderController
    end # Desktop
  end # ErpApp
end # Knitkit
