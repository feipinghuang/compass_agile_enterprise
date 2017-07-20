module Knitkit
  module WebsiteBuilder
    class HtmlTransformer
      class << self

        def insert_widget_statements(html)
          html.scan(/<%=\s*render_widget\s*:\w*\s*%>(?!\s*<\/span>)/).each do |widget_statement|
            trimmed_widget_statement = widget_statement.gsub('<%=', '')
            trimmed_widget_statement = trimmed_widget_statement.gsub('%>', '')
            trimmed_widget_statement.squeeze!

            html.gsub!(widget_statement, "<span data-widget-statement='#{trimmed_widget_statement}'>#{widget_statement}</span>")
          end

          html
        end

        def reduce_to_builder_html(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(escape_erb(html))

          #find widgets and replace them with their render statements
          doc.css('.compass_ae-widget').each do |node|
            render_statement = node.parent.attributes['data-widget-statement'].value
            node.add_next_sibling(escape_erb("<%= #{render_statement} %>"))
            node.remove
          end

          # remove editor code
          editedContents = doc.css('.editContent')
          editedContents.remove_class('medium-editor-element')
          editedContents.remove_attr('contenteditable')
          editedContents.remove_attr('spellcheck')
          editedContents.remove_attr('role')
          editedContents.remove_attr('data-placeholder')
          editedContents.remove_attr('data-medium-editor-element')
          editedContents.remove_attr('aria-multiline')
          editedContents.remove_attr('data-medium-editor-editor-index')
          editedContents.remove_attr('medium-editor-index')
          editedContents.remove_attr('data-medium-focused')

          CGI.unescape_html(doc.to_s)
        end

        def reduce_to_website_html(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(replace_widget_statement(escape_erb(html)))

          # remove data-frame-uuid
          item_content = doc.at_css('.page > .item')
          item_content.remove_attribute('data-frame-uuid') if item_content

          # find and strip off drag drop attributes from drop component
          doc.css('.dnd-drop-target > [draggable="true"]').each do |tag|
            tag.attributes['draggable'].remove
            tag.attributes['drag-uid'].remove
          end

          # strip off drag drop and related class
          doc.css('.dnd-drop-target-occupied').remove_attr('data-widget-statement')
          doc.css('.dnd-drop-target').remove_class('dnd-drop-target')
          doc.css('.dnd-drop-target-occupied').remove_class('dnd-drop-target-occupied')

          #preserve user added styles and reset everything else
          editedContents = doc.css('.editContent')
          editedContents.each do |tag|
            styles_attr = tag.attributes['style']
            if styles_attr
              styles = styles_attr.value.split(';')
              updated_styles = styles.collect do |style|
                attr,value = style.split(':')
                if attr == 'outline'
                  'outline: none';
                elsif attr == 'cursor'
                  'cursor: inherit'
                elsif attr == 'outline-offset'
                  'outline-offset: 0px'
                else
                  "#{attr}:#{value}"
                end
              end
              tag.attributes['style'].value = updated_styles.join('; ')
            end
          end
        
          CGI.unescape_html(doc.to_s)
        end
        
        def escape_erb(html)
          html.
            gsub("<%", "&lt;%").
            gsub("%>", "%&gt;").
            gsub(/(?<=&lt;%)(.*?)(?=%&gt;)/) {|w| CGI.escape_html(w)}
        end

        def replace_widget_statement(html)
          html.gsub("render_builder_widget", "render_widget")
        end
        
      end
    end
  end
end
