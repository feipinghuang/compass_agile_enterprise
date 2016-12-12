module Api
  module V1
    class WebsiteBuilderController < BaseController
      ## Component images
      HEADERS = [ { id: 'header1', img_src: '/website_builder/header1.png', height: 530, html_src: '/website_builder/header1.html'},
                            { id: 'header2', img_src: '/website_builder/header2.png', height: 550, html_src: '/website_builder/header2.html'} ]
      CONTENT_SECTIONS = [ { id: 'content_section1', img_src: '/website_builder/content_section1.png', height: 550, html_src: '/website_builder/content_section1.html'},
                                                { id: 'content_section2', img_src: '/website_builder/content_section2.png', height: 550, html_src: '/website_builder/content_section2.html'},
                                                { id: 'content_section3', img_src: '/website_builder/content_section3.png', height: 1200, html_src: '/website_builder/content_section3.html'},
                                                { id: 'content_section4', img_src: '/website_builder/content_section4.png', height: 350, html_src: '/website_builder/content_section4.html'},
                                                { id: 'content_section5', img_src: '/website_builder/content_section5.png', height: 550, html_src: '/website_builder/content_section5.html'} ]
      FOOTERS = [ { id: 'footer1', img_src: '/website_builder/footer1.png', height: 300, html_src: '/website_builder/footer1.html'},
                             { id: 'footer2', img_src: '/website_builder/footer2.png', height: 200, html_src: '/website_builder/footer2.html' } ]

      def index

      end

      def headers
        render json: {
                   success: true,
                   srcs:HEADERS
               }
      end

      def content_sections
        render json: {
                   success: true,
                   srcs:CONTENT_SECTIONS
               }
      end

      def footers
        render json: {
                   success: true,
                   srcs:FOOTERS
               }
      end

      def get_header_component
        render json: {
                   success: true,
                   data: search_component(HEADERS, params[:id])
               }
      end

      def get_content_section_component
        render json: {
                   success: true,
                   data:  search_component(CONTENT_SECTIONS, params[:id])
               }
      end

      def get_footer_component
        render json: {
                   success: true,
                   data: search_component(FOOTERS, params[:id])
               }
      end

      private

      def search_component(static_components, component_id)
          component = static_components.detect { |components| components[:id] == params[:id]}
        # "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{static_components.detect { |components| components[:id] == params[:id]}[:html_src]}"
      end

    end # WebsitesController
  end # V1
end # Api
