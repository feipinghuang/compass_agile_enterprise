module RailsDbAdmin
  module Reports

    class BaseController < ::ErpApp::ApplicationController
      layout nil
      before_filter :require_login

      def show
        report_helper = RailsDbAdmin::Services::ReportHelper.new

        respond_to do |format|

          format.html {

            result = report_helper.build_report(params[:iid],
                                                [:html],
                                                build_report_params)
            if result.is_a? String
              @error = result
              render :error_report
            else
              render inline: result.first[:data]
            end
          }

          format.pdf {
            result = report_helper.build_report(params[:iid],
                                                [:pdf],
                                                build_report_params)

            if result.is_a? String
              @error = result
              render :error_report
            else
              send_data result.first[:data],
                        filename: result.first[:name],
                        type: 'application/pdf',
                        disposition: :inline
            end
          }

          format.csv {
            result = report_helper.build_report(params[:iid],
                                                [:csv],
                                                build_report_params)
            if result.is_a? String
              @error = result
              render :error_report
            else
              send_data result.first[:data],
                        filename: result.first[:name],
                        type: 'application/csv'
            end
          }

        end

      end

      def email
        report_helper = RailsDbAdmin::Services::ReportHelper.new
        file_attachments = report_helper.build_report(params[:iid],
                                                      params[:report_format].map { |format| format.to_sym },
                                                      build_report_params)

        if file_attachments.is_a? String
          render :json => {success: false, message: file_attachments}
        else
          to_email = params[:send_to]
          cc_email = params[:cc_email]
          message = params[:message].blank? ? "Attached is report #{@report.name}" : params[:message]
          subject = params[:subject].blank? ? "Attached is report #{@report.name}" : params[:subject]

          ReportMailer.email_report(to_email, cc_email, file_attachments, subject, message, current_user.party.dba_organization).deliver

          render json: {success: true}
        end

      rescue StandardError => ex
        Rails.logger.error ex.message
        Rails.logger.error ex.backtrace.join("\n")

        # email notification
        ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

        render :json => {success: false, message: ex.message}
      end

      protected

      # Get the report data by running executing the sql
      #
      def build_report_params
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

        if params[:business_module_id].present?
          parsed_report_params[:business_module_id] = params[:business_module_id]
        end

        parsed_report_params
      end

    end # BaseController
  end # Reports
end # RailsDbAdmin
