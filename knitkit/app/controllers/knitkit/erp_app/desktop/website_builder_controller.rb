module Knitkit
  module ErpApp
    module Desktop
      class WebsiteBuilderController < Knitkit::ErpApp::Desktop::AppController

        before_filter :set_website, :only => [:components, :save_website, :active_website_theme, :render_component, :render_layout_file, :save_component_source]

        acts_as_themed_controller website_builder: true

        skip_before_filter :add_theme_view_paths, except: [:render_component, :widget_source]

        def components
          theme = @website.themes.active.first

          components = []

          if params[:is_theme].to_bool
            components << theme.block_templates(:header)
            components << theme.block_templates(:footer)
            components.flatten!
          else
            components = theme.block_templates(:content)
          end

          render json: {
            success: true,
            components: components
          }
        end

        def active_website_theme
          render json: {
            success: true,
            theme: (@website.themes.active.first.to_data_hash rescue "")
          }
        end

        def render_component
          # ensure browser doesn't block access to the iframe which renders this action
          response.headers['X-XSS-Protection'] = "0"
          @website_sections = @website.website_sections
          @website_builder = true
          source = URI.unescape(params[:source]) rescue nil
          
          if source.present? and source != "undefined" and source != "null" 
            source_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(source)
            render inline: wrap_in_row(source_html), layout: 'knitkit/base'
          elsif params[:website_section_content_id]
            website_section_content = WebsiteSectionContent.find(params[:website_section_content_id])

            render inline: wrap_in_row(website_section_content.builder_html), layout: 'knitkit/base'

          elsif params[:component_name]
            render inline: wrap_in_row(render_to_string template: "/components/#{params[:component_type]}/#{params[:component_name]}"), layout: 'knitkit/base'

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
                      # if the content block has dynamic content we don't want to process them
                      unless website_section_content.is_content_dynamic || data[:body_html].blank?

                        website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(data[:body_html])
                        # strip off design specific HTML
                        website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(website_section_content.builder_html)
                        # the content is dynamic if the source has a pair of script or erb (<%>) tags 
                        website_section_content.is_content_dynamic = website_section_content.website_html.match(/<script>(?:.*)<\/script>/m).is_a?(MatchData) ||
                                                                     website_section_content.website_html.match(/<%(?:.*)%>/m).is_a?(MatchData)

                      end
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
                      # the content is dynamic if the source has a pair of script or erb (<%>) tags 
                      website_section_content.is_content_dynamic = website_section_content.website_html.match(/<script>(?:.*)<\/script>/m).is_a?(MatchData) ||
                                                                   website_section_content.website_html.match(/<%(?:.*)%>/m).is_a?(MatchData)

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

            if params[:website_section_content_id].present?
              website_section_content = WebsiteSectionContent.find(params[:website_section_content_id])
              
              body_html = params[:body_html]
              html_content = if body_html.present?
                               builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(body_html)
                               ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(builder_html)
                             else
                               website_section_content.website_html
                             end 

            else
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
                "_#{params[:component_type]}.html.erb"
              )

              html_content = file_support.get_contents(path).first 

            end

            render json: {
              success: true,
              component: {
                html: html_content,
              }
            }

          rescue Exception => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render json: {success: false}
          end
        end

        def component_dynamic_status
          website_section_content = WebsiteSectionContent.find(params[:website_section_content_id])
          render json: {success: true, is_content_dynamic: website_section_content.is_content_dynamic}
        end
        
        def save_component_source
          begin
            component_source = params[:source]
            component_type = params[:component_type]
            if component_type.present? and ['header', 'footer'].include?(component_type)
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
                "_#{params[:component_type]}.html.erb"
              )
              
              file_support.update_file(path, component_source)
              theme.meta_data[component_type]['builder_html'] = component_source
              theme.save!
            else
              website_section_content = WebsiteSectionContent.where(id: params[:website_section_content_id]).first

              # the content is dynamic if the source has a pair of script or erb (<%>) tags 
              website_section_content.is_content_dynamic = component_source.match(/<script>(?:.*)<\/script>/m).is_a?(MatchData) ||
                                                           component_source.match(/<%(?:.*)%>/m).is_a?(MatchData)
              # assign source
              website_section_content.website_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_website_html(component_source)
              website_section_content.builder_html = ::Knitkit::WebsiteBuilder::HtmlTransformer.reduce_to_builder_html(component_source)
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

        def set_website
          @website = Website.find(params[:id])
        end

        def set_website_section
          @website_section = WebsiteSection.find(params[:id])
        end

        def wrap_in_row(html)
          view = ActionView::Base.new

          content = view.content_tag :div, class: 'container' do

            view.content_tag :div, class: 'row' do

              view.content_tag(:div, html.html_safe, class: "col-md-12")

            end # row

          end # container

          view.raw content
        end

      end # WebsitesController
    end # Desktop
  end # ErpApp
end # Knitkit
