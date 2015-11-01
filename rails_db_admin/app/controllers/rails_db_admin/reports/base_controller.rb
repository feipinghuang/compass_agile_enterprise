module RailsDbAdmin
  module Reports

    class BaseController < RailsDbAdmin::ErpApp::Desktop::BaseController

      before_filter :set_report

      acts_as_report_controller

      def show
        if @report.nil? or @report.query.nil?
          render :no_report, :layout => false
        else
          build_report_data

          if @data[:error]
            @error = @data[:error]
            render :error_report, :layout => false
            return
          end

          respond_to do |format|

            format.html {
              render(inline: @report.template,
                     locals:
                         {
                             unique_name: @report_iid,
                             title: @report.name,
                             columns: @data[:columns],
                             rows: @data[:rows],
                             custom_data: @custom_data
                         }
              )
            }

            format.pdf {
              render build_pdf_config
            }

            format.csv {
              csv_data = CSV.generate do |csv|
                csv << @data[:columns]
                @data[:rows].each do |row|
                  csv << row.values
                end
              end

              send_data csv_data
            }

          end
        end

      end

      def email
        build_report_data

        file_attachments = []

        params[:report_format].each do |format|
          if format == 'pdf'
            file_attachments << {
                name: "#{@report.name}.pdf",
                data: render_to_string(build_pdf_config)
            }
          elsif format == 'csv'
            csv_data = CSV.generate do |csv|
              csv << @data[:columns]
              @data[:rows].each do |row|
                csv << row.values
              end
            end

            file_attachments << {
                name: "#{@report.name}.csv",
                data: csv_data
            }
          end
        end

        to_email = params[:send_to]
        cc_email = params[:cc_email]
        message = params[:message].blank? ? "Attached is report #{@report.name}" : params[:message]
        subject = params[:subject].blank? ? "Attached is report #{@report.name}" : params[:subject]

        ReportMailer.email_report(to_email, cc_email, file_attachments, subject, message).deliver

        render json: {success: true}
      end

      protected

      # build configuration to render a pdf of a report
      #
      def build_pdf_config
        {
            :pdf => "#{@report.internal_identifier}",
            :template => 'base.html.erb',
            :locals =>
                {
                    unique_name: @report_iid,
                    title: @report.name,
                    columns: @data[:columns],
                    rows: @data[:rows],
                    custom_data: @custom_data
                },
            :show_as_html => params[:debug].present?,
            :page_size => @report.meta_data['print_page_size'] || 'A4',
            :margin => {
                :top => (@report.meta_data['print_margin_top'].blank? ? 10 : @report.meta_data['print_margin_top'].to_i),
                :bottom => (@report.meta_data['print_margin_bottom'].blank? ? 10 : @report.meta_data['print_margin_bottom'].to_i),
                :left => (@report.meta_data['print_margin_left'].blank? ? 10 : @report.meta_data['print_margin_left'].to_i),
                :right => (@report.meta_data['print_margin_right'].blank? ? 10 : @report.meta_data['print_margin_right'].to_i),

            },
            :footer => {
                :right => 'Page [page] of [topage]'
            }
        }
      end

      # Get the report data by running executing the sql
      #
      def build_report_data
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

        @data = {:columns => columns, :rows => values, error: error}

        if @data[:rows].count > 0
          @custom_data = @data[:rows].last['custom_fields'] ? JSON.parse(@data[:rows].last['custom_fields']) : {}
        else
          @custom_data = {}
        end
      end

      # Load the report by internal identifier and set to an instance variable
      #
      def set_report
        @report_iid = params[:iid]
        @report = Report.find_by_internal_identifier(@report_iid)
      end

    end # BaseController
  end # Reports
end # RailsDbAdmin
