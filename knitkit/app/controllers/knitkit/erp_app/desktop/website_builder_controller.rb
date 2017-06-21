module Knitkit
  module ErpApp
    module Desktop
      class WebsiteBuilderController < Knitkit::ErpApp::Desktop::AppController

        before_filter :set_website, :only => [:save_website, :active_website_theme, :render_component, :render_layout_file, :save_component_source]

        acts_as_themed_controller website_builder: true

        skip_before_filter :add_theme_view_paths, except: [:render_component, :widget_source]

        def components

          if params[:is_theme].to_bool
            components = Component.where(Component.matches_is_json('custom_data', 'header', 'component_type',).or(Component.matches_is_json('custom_data', 'footer', 'component_type')))
          else
            components = Component.with_json_attr('custom_data', 'component_type', 'content_section')
          end

          render json: {
            success: true,
            components: components.to_data_hash
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
          @website_sections = @website.website_sections
          @website_builder = true

          if params[:website_section_content_id]
            website_section_content = WebsiteSectionContent.find(params[:website_section_content_id])

            render inline: website_section_content.builder_html, layout: 'knitkit/base'
          else
            render template: "/components/#{params[:component_iid]}", layout: 'knitkit/base'
          end
        end

        def website
          @website
        end

        def save_website
          begin
            result = {success: false}
            contents_data = JSON.parse(params["content"])

            current_user.with_capability('create', 'WebsiteSection') do
              begin
                ActiveRecord::Base.transaction do
                  website_section = @website.website_sections.where(id: params[:website_section_id]).first

                  contents_data.each do |data|
                    data = Hash.symbolize_keys(data)

                    if data[:website_section_content_id]
                      website_section_content = WebsiteSectionContent.find(data[:website_section_content_id])

                      website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(data[:body_html])
                      # strip off design specific HTML
                      website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(website_section_content.builder_html)
                      website_section_content.position = data[:position]
                      website_section_content.save!

                    else
                      website_section_content = WebsiteSectionContent.new(website_section: website_section)
                      website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(data[:body_html])
                      # strip off design specific HTML
                      website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(website_section_content.builder_html)
                      website_section_content.position = data[:position]
                      website_section_content.save!

                    end

                  end

                  website_section.publish(website, 'Auto Publish', website_section.version, current_user) if website.publish_on_save?

                  result = {:success => true}
                end
              rescue => ex
                Rails.logger.error ex.message
                Rails.logger.error ex.backtrace.join("\n")

                ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

                result = {:success => false, :message => 'Could not create Section'}
              end

              render :json => result
            end

          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def get_component_source
          begin
            website = Website.find(params[:website_id])

            if params[:website_section_content_id]
              website_section_content = WebsiteSectionContent.find(params[:website_section_content_id])

              is_content_saved = true
              html_content =website_section_content.website_html
            else
              component = Component.where(internal_identifier: params[:component_iid]).first

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
              html_content = file_support.get_contents(path).first
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
            component_source = params[:source]

            if params[:template_type]
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
                "_#{params[:template_type]}.html.erb"
              )

              file_support.update_file(path, component_source)
              theme.meta_data[template_type]['builder_html'] = component_source
              theme.save!
            else
              website_section_content = WebsiteSectionContent.where(id: params[:website_section_content_id]).first

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
          website_section_contents = WebsiteSectionContent.where(website_section_id: website_section_id).order('position asc')

          render json: {
            success: true,
            website_section_contents: website_section_contents.collect(&:to_data_hash)
          }
        end

        def widget_source
          widget_content = params[:content]

          # add website_builder = true to params
          params[:website_builder] = true

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
