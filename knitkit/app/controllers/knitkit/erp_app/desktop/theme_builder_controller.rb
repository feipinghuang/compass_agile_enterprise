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

        def preview_layout
          theme = Theme.find(params[:theme_id])
          template_type = params[:template_type]
          file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
          content = ""
          content += Dir.glob("#{theme.path}/stylesheets/**/*").collect do |stylesheet|
            "<link rel= 'stylesheet' type='text/css' href='#{file_support.get_contents(stylesheet).first}'>"
          end.join("\n")
          content += Dir.glob("#{theme.path}/javascripts/**/*").collect do |javasscript|
            "<script type='text/css' src='#{file_support.get_contents(stylesheet).first}'>"
          end.join("\n")
          content += Dir.glob("#{theme.path}/images/**/*").collect do |javasscript|
            "<script type='text/css' src='#{file_support.get_contents(stylesheet).first}'>"
          end.join("\n")

          
          
        end
      end
      
    end
  end
end
