module API
  module V1
    class CategoryClassificationsController < BaseController

=begin
 @api {get} /api/v1/category_classifications
 @apiVersion 1.0.0
 @apiName GetCategoryClassifications
 @apiGroup CategoryClassification
 @apiDescription Get Category Classifications for a record

 @apiParam (query) {String} record_type Record type to filter by
 @apiParam (query) {Integer} record_id Record Id to filter by
 @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
 @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25

 @apiSuccess (200) {Object} get_category_classifications_response Response.
 @apiSuccess (200) {Boolean} get_category_classifications_response.success True if the request was successful
 @apiSuccess (200) {Number} get_category_classifications_response.total_count Total count of ProductType records
 @apiSuccess (200) {Object[]} get_category_classifications_response.category_classifications Array of CategoryClassification records
 @apiSuccess (200) {Number} get_category_classifications_response.category_classifications.id Id of CategoryClassification

=end

      def index
        if !params[:record_type].blank? && !params[:record_id].blank?
          category_classifications = CategoryClassification.where(classification_type: params[:record_type], classification_id: params[:record_id])

          limit = params[:limit] || 25
          start = params[:start] || 0

          total_count = category_classifications.count

          category_classifications = category_classifications.limit(limit).offset(start)

          render json: {success: true, total_count: total_count, category_classifications: category_classifications.collect(&:to_data_hash)}

        else
          render json: {success: false, message: 'record_type and record_id are required'}
        end
      end

=begin

 @api {get} /api/v1/category_classifications/:id
 @apiVersion 1.0.0
 @apiName GetCategoryClassification
 @apiGroup CategoryClassification
 @apiDescription Get Category Classification

 @apiParam (query) {Integer} id Id of CategoryClassification

 @apiSuccess (200) {Object} get_category_classification_response Response.
 @apiSuccess (200) {Boolean} get_category_classification_response.success True if the request was successful
 @apiSuccess (200) {Object} get_category_classification_response.category CategoryClassification record
 @apiSuccess (200) {Number} get_category_classification_response.category.id Id of CategoryClassification

=end

      def show
        category_classification = CategoryClassification.find(params[:id])

        render json: {category_classification: category_classification.to_data_hash}
      end

=begin

 @api {post} /api/v1/category_classifications/
 @apiVersion 1.0.0
 @apiName CreateCategoryClassification
 @apiGroup CategoryClassification
 @apiDescription Create Category Classification

 @apiParam (body) {String} record_type Record type to set
 @apiParam (body) {Integer} record_id Record Id to set
 @apiParam (body) {Integer} [category_id] Category record Id to set, if this is passed then category_iid should not be passed
 @apiParam (body) {String} [category_iid] Category record Internal Identifier to set, if this is passed then category_id should not be passed

 @apiSuccess (200) {Object} create_category_classification_response Response.
 @apiSuccess (200) {Boolean} create_category_classification_response.success True if the request was successful
 @apiSuccess (200) {Object} create_category_classification_response.category CategoryClassification record
 @apiSuccess (200) {Number} create_category_classification_response.category.id Id of CategoryClassification

=end

      def create

        begin
          ActiveRecord::Base.transaction do
            if !params[:record_type].blank? && !params[:record_id].blank?
              category_classification = CategoryClassification.create(classification_type: params[:record_type],
                                                                      classification_id: params[:record_id])

              if params[:category_id]
                category_classification.category_id = params[:category_id]
              end

              if params[:category_iid]
                category_classification.category = Category.where(internal_identifier: params[:category_iid])
              end

              category_classification.save!

              render json: {success: true, category_classification: category_classification.to_data_hash}

            else
              render json: {success: false, message: 'record_type and record_id are required'}

            end
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors.full_messages

          render json: {:success => false, :message => invalid.record.errors.full_messages.join('</br>')}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {:success => false, :message => "Error creating record"}
        end
      end

=begin

 @api {put} /api/v1/category_classifications/:id
 @apiVersion 1.0.0
 @apiName UpdateCategoryClassification
 @apiGroup CategoryClassification
 @apiDescription Update Category Classification

 @apiParam (body) {String} record_type Record type to set
 @apiParam (body) {Integer} record_id Record Id to set
 @apiParam (body) {Integer} [category_id] Category record Id to set, if this is passed then category_iid should not be passed
 @apiParam (body) {String} [category_iid] Category record Internal Identifier to set, if this is passed then category_id should not be passed

 @apiSuccess (200) {Object} update_category_classification_response Response.
 @apiSuccess (200) {Boolean} update_category_classification_response.success True if the request was successful
 @apiSuccess (200) {Object} update_category_classification_response.category_classification Category record
 @apiSuccess (200) {Number} update_category_classification_response.category_classification.id Id of Category Classification 

=end

      def update
        category_classification = CategoryClassification.find(params[:id])

        begin
          ActiveRecord::Base.transaction do
            if params[:record_type] and params[:record_id]
              category_classification.record_type = params[:record_type]
              category_classification.record_id = params[:record_id]
            end

            if params[:category_id]
              category_classification.category_id = params[:category_id]
            end

            if params[:category_iid]
              category_classification.category = Category.where(internal_identifier: params[:category_iid])
            end

            category_classification.save!

            render json: {success: true, category_classification: category_classification.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors.full_messages

          render json: {:success => false, :message => invalid.record.errors.full_messages.join('</br>')}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Application Error'}
        end
      end

=begin

 @api {delete} /api/v1/category_classifications/:id
 @apiVersion 1.0.0
 @apiName DestroyCategoryClassification
 @apiGroup CategoryClassification
 @apiDescription Destroy Category Classification

 @apiParam (query) {Integer} id Id of CategoryClassification

 @apiSuccess (200) {Object} destroy_category_classification_response Response.
 @apiSuccess (200) {Boolean} destroy_category_classification_response.success True if the request was successful

=end

      def destroy
        category_classification = CategoryClassification.find(params[:id])

        category_classification.destroy

        render json: {success: true}
      end

    end # CategoryClassificationsController
  end # V1
end # API
