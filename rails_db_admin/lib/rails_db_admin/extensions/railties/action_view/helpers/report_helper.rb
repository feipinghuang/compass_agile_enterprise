module RailsDbAdmin
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module ReportHelper

            def report_download_url(report_iid, format)
              raw "/reports/display/#{report_iid}.#{format}"
            end

            def report_download_link(report_iid, format, display=nil)
              display = display || "Download #{format.to_s.humanize}"
              raw "<a target='_blank' href='#{report_download_url(report_iid, format)}'>#{display}</a>"
            end

            def render_template(template, locals=nil)
              if request.format.symbol == :html
                render :partial => "/#{template}" , :locals => locals
              elsif request.format.symbol == :pdf
                render :partial => "/#{template}.html.erb" , :locals => locals
              end
            end

            def report_stylesheet_link_tag(report_id, *sources)
              report = Report.iid(report_id)
              return("could not find report with the id #{report_id}") unless report
              if request.format.symbol == :pdf
                css_path = report.stylesheet_path(sources)
                css_text = "<style type='text/css'>#{File.read(css_path)}</style>"
                css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
              else
                options = sources.extract_options!.stringify_keys
                cache = options.delete("cache")
                recursive = options.delete("recursive")
                sources = report_expand_stylesheet_sources(report, sources, recursive).collect do |source|
                  report_stylesheet_tag(report, source, options)
                end.join("\n")
                raw sources
              end
            end

            def report_javascript_include_tag(report_id, *sources)
              report = Report.iid(report_id)
              return("could not find report with the id #{report_id}") unless report
              if request.format.symbol == :pdf
                js_path = report.javascript_path(sources)
                js_text = "<script>#{File.read(js_path)}</script>"
                js_text.respond_to?(:html_safe) ? js_text.html_safe : js_text
              else
                options = sources.extract_options!.stringify_keys
                cache = options.delete("cache")
                recursive = options.delete("recursive")
                sources = report_expand_javascript_sources(report, sources, recursive).collect do |source|
                  report_javascript_src_tag(report, source, options)
                end.join("\n")
                raw sources
              end
            end

            def report_stylesheet_path(report, source)
              report = Report.iid(report) unless report.is_a?(Report)

              name, directory = name_and_path_from_source(source, "#{report.url}/stylesheets")

              file = report.files.where('name = ? and directory = ?', name, directory).first

              file.nil? ? '' : file.data.url
            end

            def report_javascript_path(report, source)
              report = Report.iid(report) unless report.is_a?(Report)

              name, directory = name_and_path_from_source(source, "#{report.url}/javascripts")

              file = report.files.where('name = ? and directory = ?', name, directory).first

              file.nil? ? '' : file.data.url
            end

            def name_and_path_from_source(source, base_directory)
              path = source.split('/')
              name = path.last

              directory = if path.length > 1
                            #remove last element
                            path.pop

                            "#{base_directory}/#{path.join('/')}"
                          else
                            base_directory
                          end

              return name, directory
            end

            def report_expand_stylesheet_sources(report, sources, recursive = false)
              if sources.include?(:all)
                all_stylesheet_files = collect_asset_files(report.base_dir + '/stylesheets', ('**' if recursive), '*.css').uniq
              else
                sources.flatten
              end
            end

            def report_expand_javascript_sources(report, sources, recursive = false)
              if sources.include?(:all)
                collect_asset_files(report.base_dir + '/javascripts', ('**' if recursive), '*.js').uniq
              else
                sources.flatten
              end
            end

            def report_stylesheet_tag(report, source, options)
              options = {"rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen",
                         "href" => html_escape(report_stylesheet_path(report, source))}.merge(options)
              tag("link", options, false, false)
            end

            def report_javascript_src_tag(report, source, options)
              options = {"type" => Mime::JS, "src" => report_javascript_path(report, source)}.merge(options)
              content_tag("script", "", options)
            end

            def report_image_tag(report_id, source, options = {})
              report = Report.iid(report_id)
              return("could not find report with the id #{report_id}") unless report

              if request.format.symbol == :pdf
                img_path = report.image_path(source)
                image_tag "file:///#{img_path}",options
              else
                options.symbolize_keys!
                options[:src] = report_image_path(report, source)
                options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

                if size = options.delete(:size)
                  options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
                end

                if mouseover = options.delete(:mouseover)
                  options[:onmouseover] = "this.src='#{report_image_path(report, mouseover)}'"
                  options[:onmouseout] = "this.src='#{report_image_path(report, options[:src])}'"
                end

                tag("img", options)
              end
            end

            def report_image_path(report, source)
              report = Report.iid(report) unless report.is_a?(Report)

              name, directory = name_and_path_from_source(source, "#{report.url}/images")

              file = report.files.where('name = ? and directory = ?', name, directory).first

              file.nil? ? '' : file.data.url
            end

            def bootstrap_load
<<<<<<< HEAD
              #wicked_pdf_stylesheet_link_tag('bootstrap')
=======
              stylesheet_link_tag "http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"
>>>>>>> 4dc10f7af2d0fa899bcad24d3dd05713cc9e6e48
            end

            def jquery_load
              javascript_include_tag "http://code.jquery.com/jquery-1.10.0.min.js"
            end

          end #ReportHelper
        end #Helpers
      end #ActionView
    end #Railties
  end #Extensions
end #RailsDbAdmin