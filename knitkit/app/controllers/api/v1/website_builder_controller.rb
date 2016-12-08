module Api
  module V1
    class WebsiteBuilderController < BaseController
      ## Component images
      HEADER_SRC = [ { id: 'header1', src: '/website_builder/header1.png', height: 530},
                                   { id: 'header2', src: '/website_builder/header2.png', height: 550} ]

      CONTENT_SECTION_SRC = [ { id: 'content_section1', src: '/website_builder/content_section1.png', height: 550},
                                                        { id: 'content_section2', src: '/website_builder/content_section2.png', height: 550},
                                                        { id: 'content_section3', src: '/website_builder/content_section3.png', height: 1200},
                                                        { id: 'content_section4', src: '/website_builder/content_section4.png', height: 350},
                                                        { id: 'content_section5', src: '/website_builder/content_section5.png', height: 550} ]

      FOOTER_SRC = [ { id: 'footer1', src: '/website_builder/footer1.png', height: 300},
                                    { id: 'footer2', src: '/website_builder/footer2.png', height: 200} ]

      ## HTML dom data
      HEADER_HTML = [ { id: 'header1', src: '/website_builder/header1.html'},
                                      { id: 'header2', src: '/website_builder/header2.html'} ]

      CONTENT_SECTION_HTML = [ { id: 'content_section1', src: '/website_builder/content_section1.html'},
                                                          { id: 'content_section2', src: '/website_builder/content_section2.html'},
                                                          { id: 'content_section3', src: '/website_builder/content_section3.html'},
                                                          { id: 'content_section4', src: '/website_builder/content_section4.html'},
                                                          { id: 'content_section5', src: '/website_builder/content_section5.html'} ]

      FOOTER_HTML = [ { id: 'footer1', src: '/website_builder/footer1.html'},
                                      { id: 'footer2', src: '/website_builder/footer2.html'} ]

      def index

      end

      def headers
        render json: {
                   success: true,
                   srcs:HEADER_SRC
               }
      end

      def content_sections
        render json: {
                   success: true,
                   srcs:CONTENT_SECTION_SRC
               }
      end

      def footers
        render json: {
                   success: true,
                   srcs:FOOTER_SRC
               }
      end

      def get_header_dom_url
        render json: {
                   success: true,
                   html_src: "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{HEADER_HTML.detect { |header| header[:id] == params[:id]}[:src]}"
               }
      end

      def get_content_section_dom_url
        render json: {
                   success: true,
                   html_src:  "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{CONTENT_SECTION_HTML.detect { |content| content[:id] == params[:id]}[:src]}"
               }
      end

      def get_footer_dom_url
        render json: {
                   success: true,
                   html_src:  "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{FOOTER_HTML.detect { |footer| footer[:id] == params[:id]}[:src]}"
               }
      end

    end # WebsitesController
  end # V1
end # Api
