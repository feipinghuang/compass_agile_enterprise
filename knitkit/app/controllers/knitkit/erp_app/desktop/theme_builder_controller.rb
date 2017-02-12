module Knitkit
  module ErpApp
    module Desktop
      class ThemeBuilderController < Knitkit::ErpApp::Desktop::AppController

        before_filter :set_website, except: :update_layout

        acts_as_themed_controller

        skip_before_filter :add_theme_view_paths, only: [:update_layout]

        layout 'knitkit/base', except: :update_layout

        def website
          @website
        end

        def update_layout
          theme = Theme.find(params[:id])
          header_html = params[:header]
          footer_html = params[:footer]
          theme.update_base_layout({
                                     header_html: header_html,
                                     footer_html: footer_html
          })
          render json: {success: true}
        end

        def render_theme_component
          path = params[:template_type]

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
