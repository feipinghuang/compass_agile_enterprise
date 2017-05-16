module Knitkit
  module WebsiteBuilder
    class HtmlTransformer
      class << self
        
        def reduce_to_website_html(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(escape_erb(html))
          # find and strip off drag drop attributes from drop component
          doc.css('.dnd-drop-target > [draggable="true"]').each do |tag|
            tag.attributes['draggable'].remove
            tag.attributes['drag-uid'].remove
          end

          # strip off drag drop and related class
          doc.css('.dnd-drop-target').remove_class('dnd-drop-target')
          doc.css('.dnd-drop-target-occupied').remove_class('dnd-drop-target-occupied')

          #strip off website builder editable contents
          
          editedContents = doc.css('.editContent')
          editedContents.remove_class('editContent')
          editedContents.remove_attr('data-selector')
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

          #preserve user added styles and reset everything else
          editedContents.each do |tag|
            styles = tag.attributes['style'].value.split(';')
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
          
          CGI.unescape_html(doc.to_s)
        end
        
        def escape_erb(html)
          html.
            gsub("<%", "&lt;%").
            gsub("%>", "%&gt;").
            gsub(/&lt;%=?(.*?) %&gt;/) {|w| CGI.escape_html(w)}
        end
      end
    end
  end
end
