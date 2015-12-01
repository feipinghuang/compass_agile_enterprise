module ErpApp
  module Desktop
    module SystemManagement
      class TypesController < ::ErpApp::Desktop::BaseController

        def index
          types = []

          if params[:klass].present? and params[:parent_id].present?
            compass_ae_type = params[:klass].constantize.find(params[:parent_id])

            compass_ae_type.children.each do |compass_ae_type_child|
              types.push({
                             server_id: compass_ae_type_child.id,
                             description: compass_ae_type_child.description,
                             internal_identifier: compass_ae_type_child.internal_identifier,
                             klass: params[:klass]
                         })
            end
          elsif params[:klass].present?
            compass_ae_type = params[:klass].constantize

            if compass_ae_type.respond_to?(:roots)
              compass_ae_type.roots.each do |record|
                types.push({
                               server_id: record.id,
                               description: record.description,
                               internal_identifier: record.internal_identifier,
                               klass: params[:klass]
                           })
              end
            else
              compass_ae_type.all.each do |record|
                types.push({
                               server_id: record.id,
                               description: record.description,
                               internal_identifier: record.internal_identifier,
                               klass: params[:klass],
                               leaf: true
                           })
              end
            end


          else
            compass_ae_types = ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsErpType.models

            types = compass_ae_types.collect do |compass_ae_type|
              {
                  description: compass_ae_type.to_s,
                  klass: compass_ae_type.to_s,
                  leaf: false
              }
            end

          end

          render json: {success: true, types: types}
        end

        def create
          begin
            ActiveRecord::Base.transaction do
              record = params[:klass].constantize.new(description: params[:description].strip,
                                                      internal_identifier: params[:internal_identifier].strip)
              record.save!

              if params[:parent_id].present?
                record.move_to_child_of(params[:klass].constantize.find(params[:parent_id]))
              end

              render json: {success: true, type: {
                         server_id: record.id,
                         description: record.description,
                         internal_identifier: record.internal_identifier,
                         klass: params[:klass]
                     }}
            end
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            # email error
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render json: {success: false, message: 'Application Error'}
          end
        end

        def update
          record = params[:klass].constantize.find(params[:id])

          begin
            ActiveRecord::Base.transaction do
              record.description = params[:description].strip
              record.internal_identifier = params[:internal_identifier].strip
              record.save!

              render json: {success: true, type: {
                         server_id: record.id,
                         description: record.description,
                         internal_identifier: record.internal_identifier,
                         klass: params[:klass]
                     }}
            end
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            # email error
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render json: {success: false, message: 'Application Error'}
          end
        end

        def destroy
          params[:klass].constantize.find(params[:id]).destroy

          render json: {success: true}
        end

      end #BaseController
    end #SystemManagement
  end #Desktop
end #ErpApp