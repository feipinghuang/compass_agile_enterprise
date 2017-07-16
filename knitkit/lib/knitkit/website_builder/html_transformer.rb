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
          editedContents = doc.css('.pen')
          editedContents.remove_attr('contenteditable')
          editedContents.remove_attr('data-toggle')
          editedContents.remove_attr('data-placeholder')
          CGI.unescape_html(doc.to_s)
        end

        def reduce_to_website_html(html)
          html.gsub("render_builder_widget", "render_widget")
        end
        
        def escape_erb(html)
          html.
            gsub("<%", "&lt;%").
            gsub("%>", "%&gt;").
            gsub(/(?<=&lt;%)(.*?)(?=%&gt;)/) {|w| CGI.escape_html(w)}
        end

      end
    end
  end
end
