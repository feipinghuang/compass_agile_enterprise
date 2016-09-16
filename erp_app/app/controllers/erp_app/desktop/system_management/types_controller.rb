module ErpApp
  module Desktop
    module SystemManagement
      class TypesController < ::ErpApp::Desktop::BaseController

        def index
          types = []
          query_filter = params[:query_filter].blank? ? nil : params[:query_filter]

          unless query_filter.nil?
            query_filter = JSON.parse(query_filter)
            query_filter.symbolize_keys!
          end

          if params[:klass].present? and params[:parent_id].present?
            compass_ae_type = params[:klass].constantize.find(params[:parent_id])

            if query_filter
              compass_ae_type.descendants.where("description ILIKE '%#{query_filter[:keyword]}%' OR internal_identifier ILIKE '%#{query_filter[:keyword]}%'").each do |descendant|
                descendant.self_and_ancestors.where("parent_id = #{compass_ae_type.id}").each do |record|
                  unless types.any? {|t| t[:server_id] == record.id}
                    types.push({
                                     server_id: record.id,
                                     description: record.description,
                                     internal_identifier: record.internal_identifier,
                                     klass: params[:klass]
                                 })
                  end
                end
              end
            else
              compass_ae_type.children.each do |compass_ae_type_child|
                types.push({
                               server_id: compass_ae_type_child.id,
                               description: compass_ae_type_child.description,
                               internal_identifier: compass_ae_type_child.internal_identifier,
                               klass: params[:klass]
                           })
              end
            end
          elsif params[:klass].present?
            compass_ae_type = params[:klass].constantize

            if query_filter
              query_results = compass_ae_type.where("description ILIKE '%#{query_filter[:keyword]}%' OR internal_identifier ILIKE '%#{query_filter[:keyword]}%'").all
              if compass_ae_type.respond_to?(:roots)
                root_ids = query_results.collect{|type| type.root.id}.uniq
              else
                root_ids = query_results.collect{|type| type.id}.uniq
              end

              unless root_ids.empty?
                compass_ae_type.where("id in (#{root_ids.join(',')})").each do |record|
                  types.push({
                                 server_id: record.id,
                                 description: record.description,
                                 internal_identifier: record.internal_identifier,
                                 klass: params[:klass]
                             })
                end
              end
            else
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
            end
          else
            compass_ae_types = ErpBaseErpSvcs::Extensions::ActiveRecord::ActsAsErpType.models

            if query_filter
              compass_ae_types.each do |compass_ae_type|
                query_results = compass_ae_type.constantize.where("description ILIKE '%#{query_filter[:keyword]}%' OR internal_identifier ILIKE '%#{query_filter[:keyword]}%'").all
                unless query_results.empty?
                  types.push({
                    description: compass_ae_type.to_s,
                    klass: compass_ae_type.to_s,
                    leaf: false
                  })

                end
              end
            else
              types = compass_ae_types.collect do |compass_ae_type|
                {
                    description: compass_ae_type.to_s,
                    klass: compass_ae_type.to_s,
                    leaf: false
               }
              end
            end

            types = types.sort_by{|t| t[:description]}
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

            render json: {success: false, message: ex.message}
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

            render json: {success: false, message: ex.message}
          end
        end

        def destroy
          params[:klass].constantize.find(params[:id]).destroy

          render json: {success: true}
        end

        def reorder
          position = params[:dropped_position]
          klass = params[:klass]
          drag_node = klass.constantize.find(params[:drag_node_id])
          dropped_on_node = klass.constantize.find(params[:dropped_on_node_id])
          reordered = true

          if drag_node.nil? or dropped_on_node.nil?
            reordered = false
          else
            if position == 'before'
              drag_node.move_to_left_of(dropped_on_node)
            elsif position == 'after'
              drag_node.move_to_right_of(dropped_on_node)
            else
              reordered = false
            end
          end

          render json: {success: reordered}
        end

      end #BaseController
    end #SystemManagement
  end #Desktop
end #ErpApp