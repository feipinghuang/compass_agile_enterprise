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
              render :pdf => "#{@report.internal_identifier}",
                :template => 'base.html.erb', :locals =>
                    {:unique_name => @report_iid, :title => @report.name, :columns => data[:columns], :rows => data[:rows]},
                :show_as_html => params[:debug].present?,
                :margin => {:top => 0,:bottom => 15, :left => 10,:right => 10},
                :footer => {
                            :right => 'Page [page] of [topage]'
                           }
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