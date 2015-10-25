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
          if data[:error]
            @error = data[:error]
            render :error_report, :layout => false
            return
          end
          
          if data[:rows].count > 0
            @custom_data = data[:rows].last['custom_fields'] ? JSON.parse(data[:rows].last['custom_fields']) : {}
          else
            @custom_data = {}
          end

          respond_to do |format|

            format.html {
              render(inline: @report.template,
                     locals:
                         {
                             unique_name: @report_iid,
                             title: @report.name,
                             columns: data[:columns],
                             rows: data[:rows],
                             custom_data: @custom_data
                         }
              )
            }

            format.pdf {
              render :pdf => "#{@report.internal_identifier}",
                     :template => 'base.html.erb',
                     :locals =>
                     {
                       unique_name: @report_iid,
                       title: @report.name,
                       columns: data[:columns],
                       rows: data[:rows],
                       custom_data: @custom_data
                     },
                     :show_as_html => params[:debug].present?,
                     :page_size => @report.meta_data['print_page_size'] || 'A4',
                     :margin => {
                       :top => (@report.meta_data['print_margin_top'].blank?? 10 : @report.meta_data['print_margin_top'].to_i),
                       :bottom => (@report.meta_data['print_margin_bottom'].blank?? 10 : @report.meta_data['print_margin_bottom'].to_i),
                       :left => (@report.meta_data['print_margin_left'].blank?? 10 : @report.meta_data['print_margin_left'].to_i),
                       :right => (@report.meta_data['print_margin_right'].blank?? 10 : @report.meta_data['print_margin_right'].to_i),
                       
                     },
                     :footer => {
                       :right => 'Page [page] of [topage]'
                     }
              
            }
            
            format.csv {
              csv_data = CSV.generate do |csv|
                csv << data[:columns]
                data[:rows].each do |row|
                  csv << row.values
                end
              end

              send_data csv_data
            }

          end
        end
      end

      def get_report_data
        report_params = params[:report_params]
        parsed_report_params = if report_params
                                 JSON.parse(report_params).symbolize_keys
                               else
                                 nil
                               end

        # add current_user to locals
        parsed_report_params[:current_user] = current_user

        query = RailsDbAdmin::ErbStringParser.render(
          @report.query,
          locals: parsed_report_params
        )

        columns, values, error = @query_support.execute_sql(query)
        {:columns => columns, :rows => values, error: error}
      end
      
      def set_report
        @report_iid = params[:iid]
        @report = Report.find_by_internal_identifier(@report_iid)
      end

    end #BaseController
  end #Reports
end #RailsDbAdmin
