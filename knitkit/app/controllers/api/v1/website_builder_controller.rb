module Api
  module V1
    class WebsiteBuilderController < BaseController
      before_filter :set_website, :only => [:save_website]

      def components
        render json: {
          success: true,
          components: Component.to_data_hash
        }
      end

      def get_component
        render json: {
          success: true,
          data: find_component(params[:id]).to_data_hash
        }
      end

      def save_website
        begin
          result = {success: false}
          contents_data = JSON.parse(params["content"])

          if contents_data
            current_user.with_capability('create', 'WebsiteSection') do

              begin
                ActiveRecord::Base.transaction do
                  website_section = @website.website_sections.where(title: @website.name).first || WebsiteSection.new
                  website_section.parent_id = params[:website_section_id] if params[:website_section_id]
                  website_section.website_id = @website.id
                  website_section.in_menu = params[:in_menu] == 'yes'
                  website_section.title = @website.name
                  website_section.render_base_layout = params[:render_with_base_layout] == 'yes'
                  website_section.type = params[:type] unless params[:type] == 'Page'
                  website_section.internal_identifier = params[:internal_identifier]
                  website_section.position = 0 # explicitly set position null, MS SQL doesn't always honor column default

                  website_section.website_section_contents.destroy_all

                  contents_data.each do |data|
                    website_section.website_section_contents.build(content: Content.where(internal_identifier: data["content_iid"]).first, position: data["position"], body_html: data["body_html"])
                  end

                  if website_section.save
                    if params[:website_section_id]
                      parent_website_section = WebsiteSection.find(params[:website_section_id])
                      website_section.move_to_child_of(parent_website_section)
                    end

                    website_section.update_path!
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

      def set_website
        @website = Website.find(params[:id])
      end

      def set_website_section
        @website_section = WebsiteSection.find(params[:id])
      end

    end # WebsitesController
  end # V1
end # Api
