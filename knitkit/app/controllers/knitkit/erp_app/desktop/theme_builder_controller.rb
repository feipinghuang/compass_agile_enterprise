module Knitkit
  module ErpApp
    module Desktop
      class ThemeBuilderController < Knitkit::ErpApp::Desktop::AppController

        before_filter :set_website, except: :update_layout
        
        acts_as_themed_controller website_builder: true

        skip_before_filter :add_theme_view_paths, only: [:update_layout]

        layout 'knitkit/base', except: :update_layout

        def website
          @website
        end

        def update_layout
          begin
            theme = Theme.find(params[:id])
            header = JSON.parse(params[:header]) rescue {}
            footer = JSON.parse(params[:footer]) rescue {}
            
            result = theme.update_base_layout({
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
          path = params[:template_path]
          @website_builder = true
          render template: path
        end

        protected

        def set_website
          @website = Website.find(params[:website_id])
        end

      end # ThemeBuilderController
    end # Desktop
  end # ErpApp
end # Knitkit
