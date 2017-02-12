module Api
  module V1
    class WebsiteBuilderController < BaseController

      before_filter :set_website, :only => [:save_website, :active_website_theme, :render_component, :render_layout_file]

      acts_as_themed_controller

      skip_before_filter :add_theme_view_paths, except: [:render_component]

      def components
        render json: {
          success: true,
          components: Component.order('id asc').to_data_hash
        }
      end

      def get_component
        render json: {
          success: true,
          data: find_component(params[:id]).to_data_hash
        }
      end

      def active_website_theme
        render json: {
          success: true,
          theme: (current_theme.to_data_hash rescue "")
        }
      end

      def render_component
        component_iid = params[:component_iid]

        @website_builder = true

        render template: "/components/#{component_iid}", layout: 'knitkit/base'
      end

      def website
        @website
      end

      def save_website
        begin
          result = {success: false}
          contents_data = JSON.parse(params["content"])

          if contents_data
            current_user.with_capability('create', 'WebsiteSection') do
              begin
                ActiveRecord::Base.transaction do
                  website_section = @website.website_sections.where(id: params[:website_section_id]).first
                  website_section.website_section_contents.destroy_all
                  contents_data.each do |data|
                    content = Content.where(internal_identifier: data["content_iid"]).first
                    content.website_sections <<  website_section
                    content.update_html_and_position(website_section, data["body_html"], data["position"])
                  end

                  if website_section.save!
                    result = {:success => true}
                  else
                    message = "<ul>"
                    website_section.errors.collect do |e, m|
                      message << "<li>#{e} #{m}</li>"
                    end
                    message << "</ul>"
                    result = {:success => false, :message => message}
                  end
                end
              rescue => ex
                Rails.logger.error ex.message
                Rails.logger.error ex.backtrace.join("\n")

                ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

                result = {:success => false, :message => 'Could not create Section'}
              end

              render :json => result
            end
          end
        rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
          render :json => {:success => false, :message => ex.message}
        end
      end

      private

      def find_component(component_id)
        Content.where(internal_identifier: component_id).first
      end

      def current_theme
        @theme ||=@website.themes.active.first
      end

      def set_website
        @website = Website.find(params[:id])
      end

      def set_website_section
        @website_section = WebsiteSection.find(params[:id])
      end

    end # WebsitesController
  end # V1
end # Api
