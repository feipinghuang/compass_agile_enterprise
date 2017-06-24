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
            components = Component.where(Component.matches_is_json('custom_data', 'container_section', 'component_type',).or(Component.matches_is_json('custom_data', 'content_section', 'component_type')))
          end

          render json: {
            success: true,
            components: components.to_data_hash
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

          elsif params[:component_iid]
            render template: "/components/#{params[:component_iid]}", layout: 'knitkit/base'

          else
            render inline: '<script>function loadMe(html){$("body").append($($.parseHTML(html, document, true))); $(".widget-place-holder").remove();}</script><div class="widget-place-holder" style="min-height:100px;"></div>', layout: 'knitkit/base'
          end
        end

        def render_widget
          params[:widget_name]
        end

        def website
          @website
        end

        def save_website
          begin
            result = {success: false, website_section_contents:[]}
            contents_data = JSON.parse(params["content"])

            current_user.with_capability('create', 'WebsiteSection') do
              begin
                ActiveRecord::Base.transaction do
                  website_section = @website.website_sections.where(id: params[:website_section_id]).first

                  # get the current list of website_section_contents as any ones that are not passed will be deleted
                  current_website_section_contents = website_section.website_section_contents
          
                  contents_data.each do |data|
                    data = Hash.symbolize_keys(data)
         
                    if data[:website_section_content_id]
                      website_section_content = WebsiteSectionContent.find(data[:website_section_content_id])

                      website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(data[:body_html])
                      # strip off design specific HTML
                      website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(website_section_content.builder_html)
                      website_section_content.position = data[:position]
                      website_section_content.col = data[:column]
                      website_section_content.save!

                      current_website_section_contents.delete_if{|item| item.id == website_section_content.id}

                      # send back the match id so we can update the block
                      result[:website_section_contents].push({match_id: data[:match_id], website_section_content_id: website_section_content.id})

                    else
                      website_section_content = WebsiteSectionContent.new(website_section: website_section)
                      website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(data[:body_html])
                      # strip off design specific HTML
                      website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(website_section_content.builder_html)
                      website_section_content.position = data[:position]
                      website_section_content.col = data[:column]
                      website_section_content.save!

                      current_website_section_contents.delete_if{|item| item.id == website_section_content.id}

                      # send back the match id so we can update the block
                      result[:website_section_contents].push({match_id: data[:match_id], website_section_content_id: website_section_content.id})
                    end

                  end

                  # delete any current website_section_contents that were not updates
                  current_website_section_contents.destroy_all

                  website_section.publish(website, 'Auto Publish', website_section.version, current_user) if website.publish_on_save?

                  result[:success] = true
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

            if !params[:template_type].blank?
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
              theme.meta_data[params[:template_type]]['builder_html'] = component_source
              theme.save!
            else
              website_section_content = WebsiteSectionContent.where(id: params[:website_section_content_id]).first

              # assign source
              website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.insert_widget_statements(component_source)
              website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.insert_widget_statements(component_source)
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
          website_section_contents = WebsiteSection.find(params[:website_section_id]).website_section_contents.order("position, col")

          website_section_contents_data = website_section_contents.collect(&:to_data_hash).group_by{|item| item[:position]}.values

          render json: {
            success: true,
            website_section_contents: website_section_contents_data
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
