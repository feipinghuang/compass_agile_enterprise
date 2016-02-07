module RailsDbAdmin
  module Reports

    class BaseController < RailsDbAdmin::ErpApp::Desktop::BaseController

      before_filter :set_report

      acts_as_report_controller

      def show
        begin
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
                               client_utc_offset: params[:client_utc_offset]
                           }
                )
              }

              format.pdf {
                render build_pdf_config
              }

              format.csv {
                business_module = params[:business_module_id].present? ? BusinessModule.where(id: params[:business_module_id]).first : nil

                csv_data = CSV.generate do |csv|
                  custom_data_columns = []
                  if @data[:columns].include?('custom_fields')

                    custom_data = JSON.parse(@data[:rows].first['custom_fields'])

                    if business_module
                      custom_data.each do |field_name, field_value|
                        custom_data_columns << business_module.organizer_view.selected_fields.where('field_name = ?', field_name).first.label
                      end
                    else
                      custom_data_columns = custom_data.keys
                    end

                    # remove the custom_fields column if it exists
                    @data[:columns].delete('custom_fields')
                  end

                  csv << @data[:columns] + custom_data_columns

                  @data[:rows].each do |row|
                    custom_values = []

                    custom_fields = row.delete('custom_fields')

                    unless custom_fields.blank?
                      custom_data = JSON.parse(custom_fields)

                      if business_module
                        custom_data.each do |field_name, field_value|
                          case business_module.organizer_view.selected_fields.where('field_name = ?', field_name).first.field_type.internal_identifier
                            when 'address'
                              unless field_value.blank?
                                custom_values << "#{field_value['address_line_1']} #{field_value['address_line_2']} #{field_value['city']} #{field_value['state']}, #{field_value['zip']} #{field_value['country']}"
                              end
                            else
                              custom_values << field_value
                          end

                        end
                      else
                        custom_values = custom_data.values
                      end
                    end

                    csv << row.values + custom_values
                  end
                end

                send_data csv_data
              }

            end
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

      rescue StandardError => ex
        Rails.logger.error ex.message
        Rails.logger.error ex.backtrace.join("\n")

        # email notification
        ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

        render :json => {success: false, message: ex.message}
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
                    client_utc_offset: params[:client_utc_offset]
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

        parsed_report_params = if report_params.blank?
                                 {}
                               else
                                 JSON.parse(report_params).symbolize_keys
                               end

        # add current_user to locals
        parsed_report_params[:current_user] = current_user

        # add utc offset if it wasn't in the report params
        if parsed_report_params[:client_utc_offset].blank?
          parsed_report_params[:client_utc_offset] = params[:client_utc_offset]
        end

        query = RailsDbAdmin::ErbStringParser.render(
            @report.query,
            locals: parsed_report_params
        )
        columns, values, error = @query_support.execute_sql(query)

        @data = {:columns => columns, :rows => values, error: error}
      end

      # Build CSV data for report
      #
      def build_csv

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
