require 'fileutils'
require 'csv'

module RailsDbAdmin
  class ReportSupport < QuerySupport

    def initialize()
      @connection = RailsDbAdmin::ConnectionHandler.create_connection_class(Rails.env).connection
    end

    def render_report(iid, format=:html)
      report = Report.find_by_internal_identifier(iid.to_s)

      if report.nil? or report.query.nil?
        "Invalid Report, make sure report exists and query is valid"
      else
        data = get_report_data(iid)

        case format
          when :html
            ActionView::Base.new(resolver(report)).render(:inline => report.template, :locals =>
                {:unique_name => iid, :title => report.name, :columns => data[:columns], :rows => data[:rows]}
            )
          when :pdf
            html = ActionView::Base.new().render(:inline => report.template, :locals =>
                {:unique_name => iid, :title => report.name, :columns => data[:columns], :rows => data[:rows]}
            )

            kit = PDFKit.new(html, :page_size => 'Letter')
            kit.to_pdf
          when :csv
            CSV.generate do |csv|
              csv << data[:columns]
              data[:rows].each do |row|
                csv << row.values
              end
            end
        end
      end

    end

    def get_report_data(iid)
      report = Report.find_by_internal_identifier(iid.to_s)
      columns, values = self.execute_sql(report.query)

      return {:columns => columns, :rows => values}
    end

    def resolver(report)
      report_resolver = case Rails.application.config.erp_tech_svcs.file_storage
                        when :s3
                          resolver = File.join(report.url, "templates")
                        when :filesystem
                          resolver = File.join(report.base_dir, "templates")
                        end
      report_resolver
    end


  end #ReportSupport
end #RailsDbAdmin
