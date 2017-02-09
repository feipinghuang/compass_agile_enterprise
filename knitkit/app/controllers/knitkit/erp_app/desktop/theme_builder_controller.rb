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
          theme = Theme.find(params[:id])
          template_type = params[:template_type]
          template_path = "#{theme.path}/templates/shared/knitkit"
          file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
          content = ""
          content += Dir.glob("#{theme.path}/stylesheets/**/*.css").collect do |stylesheet|
            "<style type='text/css'>#{file_support.get_contents(stylesheet).first}</style>"
          end.join("\n")
          content += Dir.glob("#{theme.path}/javascripts/**/*.js").collect do |javasscript|
            "<script type='text/javasscript'>#{file_support.get_contents(javasscript).first}</script>"
          end.join("\n")
          # content += Dir.glob("#{theme.path}/images/**/*").collect do |image|
          #   "<script type='text/css' src='#{file_support.get_contents(image).first}'>"
          # end.join("\n")

          if File.file?("#{template_path}/_#{template_type}.html.erb")
            content += IO.read("#{template_path}/_#{template_type}.html.erb")
          end
          render inline: content.html_safe, layout: false
        end

      end
    end
  end
end
