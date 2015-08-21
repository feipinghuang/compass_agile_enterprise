module RailsDbAdmin
  module Reports

    class BaseController < RailsDbAdmin::ErpApp::Desktop::BaseController

      before_filter :set_report

      acts_as_report_controller

      def show
        if @report.nil? or @report.query.nil?
          render :no_report, :layout => false
        else
          data = get_report_data

          respond_to do |format|

            format.html {
              render(:inline => @report.template, :locals =>
                  {:unique_name => @report_iid, :title => @report.name, :columns => data[:columns], :rows => data[:rows]}
              )
            }

            format.pdf {
              html = render(:inline => @report.template, :locals =>
                  {:unique_name => @report_iid, :title => @report.name, :columns => data[:columns], :rows => data[:rows]}
              )
              kit = PDFKit.new(html, :page_size => 'Letter')
              kit.to_pdf
            }

            format.csv {
              CSV.generate do |csv|
                csv << data[:columns]
                data[:rows].each do |row|
                  csv << row.values
                end
              end
            }

          end
        end
      end

      def get_report_data
        columns, values = @query_support.execute_sql(@report.query)
        return {:columns => columns, :rows => values}
      end

      def set_report
        @report_iid = params[:iid]
        @report = Report.find_by_internal_identifier(@report_iid)
      end

    end #BaseController
  end #Reports
end #RailsDbAdmin