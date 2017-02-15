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
          path = params[:template_path]
          type = params[:template_type]
          @website_builder = true
          theme_id = params[:theme_id]
          theme = Theme.find_by_id(theme_id)
          if theme and theme.is_layout_updated?
            render template: path
          else
            render inline: "<div style='text-align:center;font-familiy:helvetica, arial, verdana, sans-serif;font-size:25px;font-weight:normal;color:#666;'>Drop #{type.capitalize} Here</div>"
          end
        end

        protected

        def set_website
          @website = Website.find(params[:website_id])
        end

      end # ThemeBuilderController
    end # Desktop
  end # ErpApp
end # Knitkit
