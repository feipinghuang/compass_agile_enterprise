module Api
  module V1
    class WebsiteBuilderController < BaseController
      HEADER_SRC = [ { id: 'header1', src: '/website_builder/header1.png'}, { id: 'header2', src: '/website_builder/header2.png'}]
      FOOTER_SRC = [ { id: 'footer1', src: '/website_builder/footer1.png'}, { id: 'footer2', src: '/website_builder/footer2.png'}]
      HEADER_HTML = [{ id: 'header1', src: '/website_builder/header1.html'}, { id: 'header2', src: '/website_builder/header2.html'}]
      FOOTER_HTML = [{ id: 'footer1', src: '/website_builder/footer1.html'}, { id: 'footer2', src: '/website_builder/footer2.html'}]

      def index

      end

      def headers
        render json: {
                   success: true,
                   srcs: HEADER_SRC
               }
      end

      def footers
        render json: {
                   success: true,
                   srcs: FOOTER_SRC
               }
      end

      def get_header_dom_url
        render json: {
                   success: true,
                   html_src: "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{HEADER_HTML.detect { |header| header[:id] == params[:id]}[:src]}"
               }
      end

      def get_footer_dom_url
        render json: {
                   success: true,
                   html_src:  "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{FOOTER_HTML.detect { |header| header[:id] == params[:id]}[:src]}"
               }
      end

    end # WebsitesController
  end # V1
end # Api
