module API
  module V1
    class RulesetsController < BaseController

      def index
        respond_to do |format|
          format.json do
            render json: {success: true, rulesets: Ruleset.all.collect(&:to_data_hash)}
          end

          format.tree do
            render json: Ruleset.all.map{|ruleset| ruleset.to_tree}.to_json
          end
        end
      end

      def create
        begin
          ActiveRecord::Base.transaction do
            ruleset = Ruleset.create(description: params['description'], internal_identifier: params['internal_identifier'])

            render json: {success: true, ruleset: ruleset.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors.full_messages

          render json: {:success => false, :message => invalid.record.errors.full_messages.join('</br>')}
        rescue StandardError => ex
          Rails.logger.error(ex.message)
          Rails.logger.error(ex.backtrace.join("\n"))

          render :json => {success: false, message: 'Error. Please try again later.'}

        end
      end

      def update
        begin
          ActiveRecord::Base.transaction do
            ruleset = Ruleset.find(params[:id])

            ruleset.description = params[:description].strip
            ruleset.save!

            render json: {success: true, ruleset: ruleset.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors.full_messages

          render json: {:success => false, :message => invalid.record.errors.full_messages.join('</br>')}
        rescue StandardError => ex
          Rails.logger.error(ex.message)
          Rails.logger.error(ex.backtrace.join("\n"))

          render json: {success: false, message: 'Error. Please try again later.'}

        end
      end

      def destroy
        ruleset = Ruleset.find(params[:id])

        render json: {success: ruleset.destroy}
      end

      # Export a Ruleset
      #
      def export
        ruelset = Ruleset.find(params[:id])

        send_data ruelset.export.to_json, filename: "#{ruelset.description}.json", type: 'application/json'
      end

      # Import a Ruleset
      #
      def import
        file_data = params[:file]

        data = nil
        if file_data.respond_to?(:read)
          data = file_data.read

        elsif file_data.respond_to?(:path)
          data = File.read(file_data.path)

        end

        if data
          ruelset = Ruleset.import(params[:description].strip, params[:internal_identifier].strip, JSON.parse(data))

          render json: {success: true, ruleset: ruelset.to_tree}

        else
          Rails.logger.error("Bad file_data: #{file_data.class.name}: #{file_data.inspect}")

          render json: {success: false, message: 'Error processing file'}

        end
      end

    end # RulesetsController
  end # V1
end # API
