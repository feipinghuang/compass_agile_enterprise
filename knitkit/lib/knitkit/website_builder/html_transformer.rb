module Knitkit
  module WebsiteBuilder
    class HtmlTransformer
      class << self

        def insert_widget_statements(html)
          html.gsub!("render_widget", "render_builder_widget")
          html.scan(/<%=\s*render_builder_widget\s*:(?:.*)?(?<=%>)/m).each do |widget_statement|
            trimmed_widget_statement = widget_statement.gsub('<%=', '')
            trimmed_widget_statement = trimmed_widget_statement.gsub('%>', '')
            trimmed_widget_statement.squish!
            html.gsub!(widget_statement, "<div data-widget-statement=\"#{trimmed_widget_statement}\">#{widget_statement}</div>")
          end
          html
        end

        def remove_widget_statements(html)
          html.gsub!("render_builder_widget", "render_widget")
          doc = Nokogiri::HTML::DocumentFragment.parse(escape_erb(html))
          doc.css('div[data-widget-statement]').each do |node|
            widget_statement = node.attributes['data-widget-statement'].value
            node.add_next_sibling(escape_erb("<%= #{widget_statement} %>"))
            node.remove
          end
          unescape_erb(doc.to_s)
        end

        def reduce_to_builder_html(html)
          insert_widget_statements(html)
        end

        def reduce_to_website_html(html)
          remove_widget_statements(html)
        end

        def escape_erb(html)
          html.
            gsub("<%", "__ERB__&lt;%").
            gsub("%>", "__ERB__%&gt;").
            gsub(/(?<=__ERB__&lt;%)(.*?)(?=__ERB__%&gt;)/) {|w| CGI.escape_html(w)}
        end

        def unescape_erb(html)
          html.
            gsub("__ERB__&lt;%", "<%").
            gsub("__ERB__%&gt;", "%>").
            gsub(/(?<=<%)(.*?)(?=%>)/) {|w| CGI.unescape_html(w)}
        end
        
      end
    end
  end
end
