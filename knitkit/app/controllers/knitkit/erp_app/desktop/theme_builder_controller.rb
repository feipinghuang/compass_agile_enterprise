module Knitkit
  module ErpApp
    module Desktop
      class ThemeBuilderController < Knitkit::ErpApp::Desktop::AppController

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
      end
    end
  end
end
