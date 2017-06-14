module Knitkit
  module ErpApp
    module Desktop
      class WebsiteBuilderController < Knitkit::ErpApp::Desktop::AppController

        before_filter :set_website, :only => [:save_website, :active_website_theme, :render_component, :render_layout_file]

        acts_as_themed_controller website_builder: true

        skip_before_filter :add_theme_view_paths, except: [:render_component, :widget_source]

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
          component = Component.where(internal_identifier: component_iid).first
          website_section_id = params[:website_section_id]
          website_section_content = WebsiteSectionContent.where(website_section_id: website_section_id, content_id: component.id).first
          @website_builder = true
          if website_section_content
            render inline: website_section_content.builder_html, layout: 'knitkit/base'
          else
            render template: "/components/#{component_iid}", layout: 'knitkit/base'
          end
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

                      #TODO this should probably be moved into the view
                      if website_section.altered?
                        website = website_section.website
                        if website_section.save
                          website_section.publish(website, 'Auto Publish', website_section.version, current_user) if website.publish_on_save?

                          result = {:success => true}
                        else
                          result = {:success => false}
                        end
                      else
                        result = {:success => true}
                      end

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

        def get_component_source
          begin
            website = Website.find(params[:website_id])
            component = Component.where(internal_identifier: params[:component_iid]).first
            website_section_content = WebsiteSectionContent.where(
              website_section_id: params[:website_section_id],
              content_id: component.id).first
            # we want to return the source only if its saved
            is_content_saved = false
            html_content = if website_section_content
                             is_content_saved = true
                             website_section_content.website_html
                           elsif component.internal_identifier.match(/^(header|footer)/)
                             is_content_saved = true
                             template_type = component.internal_identifier.match(/^(header|footer)/)[0]
                             theme = website.themes.first
                             file_support = ErpTechSvcs::FileSupport::Base.new(
                               storage: Rails.application.config.erp_tech_svcs.file_storage
                             )
                             path = File.join(
                               file_support.root,
                               'public',
                               'sites',
                               website.internal_identifier,
                               'themes',
                               theme.theme_id,
                               'templates',
                               'shared',
                               'knitkit',
                               "_#{template_type}.html.erb"
                             )
                             file_support.get_contents(path).first
                           end
            
            if is_content_saved
              render json: {
                       success: true,
                       component: {
                         html: html_content,
                       }
                     }
            else
              render json: {success: false}
            end
          rescue Exception => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier
            
            render json: {success: false}
          end
        end

        def save_component_source
          begin
            component = Component.where(internal_identifier: params[:component_iid]).first
            component_source = params[:source]
            website = Website.find(params[:website_id])
            if component.internal_identifier.match(/^(header|footer)/)
              template_type = component.internal_identifier.match(/^(header|footer)/)[0]
              theme = website.themes.first
              file_support = ErpTechSvcs::FileSupport::Base.new(
                storage: Rails.application.config.erp_tech_svcs.file_storage
              )
              path = File.join(
                file_support.root,
                'public',
                'sites',
                website.internal_identifier,
                'themes',
                theme.theme_id,
                'templates',
                'shared',
                'knitkit',
                "_#{template_type}.html.erb"
              )
              file_support.update_file(path, component_source)
              theme.meta_data[template_type]['builder_html'] = component_source
              theme.save!
            else
              website_section_id = params[:website_section_id]
              # find website section
              website_section_content = WebsiteSectionContent.where(
                website_section_id: website_section_id,
                content_id: component.id
              ).first

              # create a website section if not there
              website_section_content = WebsiteSectionContent.new(
                website_section_id: website_section_id,
                content_id: component.id,
                position: 0
              ) unless website_section_content

              # assign source
              website_section_content.website_html = component_source
              website_section_content.builder_html = component_source
              website_section_content.save!
            end
            render json: {success: true}
          rescue Exception => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render json: {success: false}

          end

        end

        def section_components
          website_section_id = params[:website_section_id]
          website_section_contents = WebsiteSectionContent.where(website_section_id: website_section_id)
          components = if website_section_contents.present?
            Component.joins("inner join website_section_contents on contents.id = website_section_contents.content_id").where("website_section_contents.website_section_id = #{website_section_id}").order("website_section_contents.position asc").to_data_hash
          else
            []
          end
          render json: {
            success: true,
            components: components
          }

        end


        def widget_source
          widget_content = params[:content]
          source = Knitkit::WebsiteBuilder::ErbEvaluator.evaluate(widget_content, self)
          render json: {success: true, source: source}
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
    end # Desktop
  end # ErpApp
end # Knitkit
