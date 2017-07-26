module Knitkit
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module ContentHelper

            def setup_inline_editing
              if can_inline_edit?
                raw "<script type='text/javascript'>
                     jQuery(document).ready(function() {
                         new OnDemandLoadByAjax().load('/javascripts/ckeditor/ckeditor.js', function(){
                            Knitkit.InlineEditing.setup(#{@website.id});
                          });
                      });
                    </script>"
              end
            end

            def render_editable_content(content_version, additional_css_classes=[])
              raw "<div class='knitkit_content #{additional_css_classes.join(' ')}'
                        contentid='#{content_version.content.id}'
                        lastupdate='#{content_version.content.updated_at.strftime("%m/%d/%Y %I:%M%p")}'>#{content_version.body_html}</div>"
            end

            # render a piece of content by internal identifier regardless if it belongs to a section or not
            def render_content(iid)
              content = Content.find_by_internal_identifier(iid)
              content_version = Content.get_published_version(@active_publication, content) unless @active_publication.nil?
              content_version = content if @active_publication.nil? or content_version.nil?

              if content_version.nil?
                ''
              else
                raw "<div class='knitkit_content'
                        contentid='#{content.id}'
                        lastupdate='#{content_version.updated_at.strftime("%m/%d/%Y %I:%M%p")}'>
                        #{(content_version.body_html.nil? ? '' : content_version.body_html)}</div>"
              end
            end

            def render_content_area(name)
              html = ''

              section_contents = WebsiteSectionContent.includes(:content).
                  where(:website_section_id => @website_section.id, :content_area => name.to_s).
                  order(:position).all
              published_contents = []
              section_contents.each do |sc|
                content_version = Content.get_published_version(@active_publication, sc.content) unless @active_publication.nil?
                content_version = sc.content if @active_publication.nil? or content_version.nil?
                published_contents << content_version unless content_version.nil?
              end

              published_contents.each do |content|
                content_id = content.content.id rescue content.id
                html << "<div class='knitkit_content'
                        contentid='#{content_id}'
                        lastupdate='#{content.updated_at.strftime("%m/%d/%Y %I:%M%p")}'>
                        #{(content.body_html.nil? ? '' : content.body_html)}</div>"

              end

              raw html
            end

            private

            def can_inline_edit?
              result = false
              unless (current_user.nil? or current_user === false)
                if (current_user.has_capability?('edit_html', 'Content') rescue false)
                  if (@website.configurations.first.get_configuration_item(:auto_active_publications).options.first.value == 'yes' and @website.configurations.first.get_configuration_item(:publish_on_save).options.first.value == 'yes')
                    result = true
                  end #make sure auto activate and publish on save our set
                end #make sure they have this capability
              end #check for user
              result
            end

          end #ContentHelper
        end #Helpers
      end #ActionView
    end #Railties
  end #Extensions
end #Knitkit