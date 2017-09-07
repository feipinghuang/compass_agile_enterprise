module API
  module V1
    class PricingPlanAssignmentsController < BaseController

=begin

  @api {get} /api/v1/pricing_plan_assignments Index
  @apiVersion 1.0.0
  @apiName GetPricingPlanAssignments
  @apiGroup PricingPlanAssignment
  @apiDescription Get Pricing Plan Assignments

  @apiParam (query) {Integer} [pricing_plan_id] Id of PricingPlan to scope by
  @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
  @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25
  
  @apiSuccess (200) {Object} get_pricing_plan_assignments_response Response
  @apiSuccess (200) {Boolean} get_pricing_plan_assignments_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_pricing_plan_assignments_response.pricing_plan_assignments PricingPlanAssignment records
  @apiSuccess (200) {Number} get_pricing_plan_assignments_response.pricing_plan_assignments.id Id of PricingPlanAssignment

=end

      def index
        limit = params[:limit] || 25
        start = params[:start] || 0

        pricing_plan_assignments = PricingPlanAssignment

        total_count = pricing_plan_assignments.count

        pricing_plan_assignments = pricing_plan_assignments.limit(limit).offset(start)

        render :json => {success: true, total_count: total_count, pricing_plan_assignments: pricing_plan_assignments.collect(&:to_data_hash)}
      end

=begin

  @api {post} /api/v1/pricing_plan_assignments Create
  @apiVersion 1.0.0
  @apiName CreatePricingPlanAssignment
  @apiGroup PricingPlanAssignment
  @apiDescription Create Pricing Plan Assignment

  @apiParam (body) {Integer} priceable_item_id Id of priceable item record
  @apiParam (body) {String} priceable_item_type Type of priceable item record (ex: ProductType)
  @apiParam (body) {Integer} pricing_plan_id Id of PricingPlan

  @apiSuccess (200) {Object} create_pricing_plan_assignment_response Response
  @apiSuccess (200) {Boolean} create_pricing_plan_assignment_response.success True if the request was successful
  @apiSuccess (200) {Object} create_pricing_plan_assignment_response.pricing_plan_assignment newly created PricingPlanAssignment record

=end

      def create
        begin
          ActiveRecord::Base.connection.transaction do

            pricing_plan_assignment = PricingPlanAssignment.new(priceable_item_id: params[:priceable_item_id],
                                                                priceable_item_type: params[:priceable_item_type],
                                                                pricing_plan_id: params[:pricing_plan_id])

            pricing_plan_assignment.save!

            render json: {success: true, pricing_plan_assignment: pricing_plan_assignment.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not create credit card'}
        end
      end

=begin

 @api {put} /api/v1/pricing_plan_assignments/:id
 @apiVersion 1.0.0
 @apiName UpdatePricingPlanAssignment
 @apiGroup PricingPlanAssignment
 @apiDescription Update Pricing Plan Assignment

 @apiParam (query) {Integer} id Id of PricingPlan
 @apiParam (body) {Integer} priceable_item_id Id of priceable item record
 @apiParam (body) {String} priceable_item_type Type of priceable item record (ex: ProductType)
 @apiParam (body) {Integer} pricing_plan_id Id of PricingPlan

 @apiSuccess (200) {Object} update_pricing_plan_assignment_response Response.
 @apiSuccess (200) {Boolean} update_pricing_plan_assignment_response.success True if the request was successful
 @apiSuccess (200) {Object} update_pricing_plan_assignment_response.pricing_plan_assignment PricingPlanAssignment record
 @apiSuccess (200) {Number} update_pricing_plan_assignment_response.pricing_plan_assignment.id Id of PricingPlanAssignment

=end

      def update
        pricing_plan_assignment = PricingPlanAssignment.find(params[:id])

        begin
          ActiveRecord::Base.transaction do
            if params[:priceable_item_id].present? && params[:priceable_item_type].present? and
              pricing_plan_assignment.priceable_item_id = params[:priceable_item_id]
              pricing_plan_assignment.priceable_item_type = params[:priceable_item_type]
            end

            if params[:pricing_plan_id].present?
              pricing_plan_assignment.pricing_plan_id = params[:pricing_plan_id]
            end

            pricing_plan_assignment.save!

            render json: {success: true, pricing_plan_assignment: pricing_plan_assignment.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Application Error'}
        end
      end

=begin

 @api {delete} /api/v1/pricing_plan_assignments/:id
 @apiVersion 1.0.0
 @apiName DestroyPricingPlanAssignment
 @apiGroup PricingPlanAssignment
 @apiDescription Destroy Pricing Plan Assignment

 @apiParam (query) {Integer} id Id of PricingPlanAssignment

 @apiSuccess (200) {Object} destroy_pricing_plan_assignment_response Response.
 @apiSuccess (200) {Boolean} destroy_pricing_plan_assignment_response.success True if the request was successful

=end

      def destroy
        pricing_plan_assignment = PricingPlanAssignment.find(params[:id])

        pricing_plan_assignment.destroy

        render json: {success: true}
      end

    end # PricingPlanAssignmentsController
  end # V1
end # API
