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
              render :partial => "/#{template}" , :locals => locals
            end

          end #ReportHelper
        end #Helpers
      end #ActionView
    end #Railties
  end #Extensions
end #RailsDbAdmin