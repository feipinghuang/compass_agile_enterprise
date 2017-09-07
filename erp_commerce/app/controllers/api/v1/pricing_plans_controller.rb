module API
  module V1
    class PricingPlansController < BaseController

=begin

  @api {get} /api/v1/pricing_plans
  @apiVersion 1.0.0
  @apiName GetPricingPlans
  @apiGroup PricingPlan
  @apiDescription Get Pricing Plans

  @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
  @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
  @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25
  
  @apiSuccess (200) {Object} get_pricing_plans_response Response
  @apiSuccess (200) {Boolean} get_pricing_plans_response.success True if the request was successful
  @apiSuccess (200) {Object[]} get_pricing_plans_response.pricing_plans PricingPlan records
  @apiSuccess (200) {Number} get_pricing_plans_response.pricing_plans.id Id of PricingPlan

=end

      def index
        sort = 'description'
        dir = 'ASC'
        limit = nil
        start = nil

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'description'
          dir = sort_hash[:direction] || 'ASC'
        end

        limit = params[:limit] || 25
        start = params[:start] || 0

        pricing_plans = PricingPlan

        total_count = pricing_plans.count

        pricing_plans = pricing_plans.order("#{sort} #{dir}").offset(start).limit(limit)

        render :json => {success: true, total_count: total_count, pricing_plans: pricing_plans.collect(&:to_data_hash)}
      end

=begin

  @api {post} /api/v1/pricing_plans
  @apiVersion 1.0.0
  @apiName CreatePricingPlan
  @apiGroup PricingPlan
  @apiDescription Create Pricing Plan

  @apiParam (body) {String} description Description
  @apiParam (body) {String} internal_identifier Internal Identifier
  @apiParam (body) {String} external_identifier External Identifier
  @apiParam (body) {String} external_id_source External Id Source
  @apiParam (body) {String} comments Comments
  @apiParam (body) {Date} from_date From Date
  @apiParam (body) {Date} thru_date Thru Date
  @apiParam (body) {Boolean} is_simple_amount If this is a simple amount PricingPlan
  @apiParam (body) {String} currency_iid Currency Internal Identifier (ex: USD)
  @apiParam (body) {Decimal} money_amount Amount if this is a simple amount

  @apiSuccess (200) {Object} create_pricing_plan_response Response
  @apiSuccess (200) {Boolean} create_pricing_plan_response.success True if the request was successful
  @apiSuccess (200) {Object} create_pricing_plan_response.pricing_plan newly created PricingPlan record
  @apiSuccess (200) {Integer} create_pricing_plan_response.pricing_plan.id Id of PricingPlan

=end

      def create
        begin
          ActiveRecord::Base.connection.transaction do

            pricing_plan = PricingPlan.new(description: params[:description],
                                           internal_identifier: params[:internal_identifier],
                                           external_identifier: params[:external_identifier],
                                           external_id_source: params[:external_id_source],
                                           comments: params[:comments],
                                           is_simple_amount: params[:is_simple_amount],
                                           currency: Currency.find_by_internal_identifier(params[:currency_iid]),
                                           money_amount: params[:money_amount])

            pricing_plan.save!

            if params[:from_date].present?
              pricing_plan.from_date = params[:from_date].to_date
            end

            if params[:thru_date].present?
              pricing_plan.thru_date = params[:thru_date].to_date
            end

            pricing_plan.set_tenant!(current_user.party.dba_organization)

            render json: {success: true, pricing_plan: pricing_plan.to_data_hash}

          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue StandardError => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not create PricingPlan'}
        end
      end

=begin

 @api {put} /api/v1/pricing_plans/:id
 @apiVersion 1.0.0
 @apiName UpdatePricingPlan
 @apiGroup PricingPlan
 @apiDescription Update Pricing Plan

 @apiParam (query) {Integer} id Id of PricingPlan
 @apiParam (body) {String} [description] Description
 @apiParam (body) {String} [internal_identifier] Internal Identifier
 @apiParam (body) {String} [external_identifier] External Identifier
 @apiParam (body) {String} [external_id_source] External Id Source
 @apiParam (body) {String} [comments] Comments
 @apiParam (body) {Date} [from_date From Date
 @apiParam (body) {Date} [thru_date] Thru Date
 @apiParam (body) {Boolean} [is_simple_amount] If this is a simple amount PricingPlan
 @apiParam (body) {String} [currency_iid] Currency Internal Identifier (ex: USD)
 @apiParam (body) {Float} [money_amount] Amount if this is a simple amount

 @apiSuccess (200) {Object} update_pricing_plan_response Response.
 @apiSuccess (200) {Boolean} update_pricing_plan_response.success True if the request was successful
 @apiSuccess (200) {Object} update_pricing_plan_response.pricing_plan PricingPlan record
 @apiSuccess (200) {Number} update_pricing_plan_response.pricing_plan.id Id of PricingPlan

=end

      def update
        pricing_plan = PricingPlan.find(params[:id])

        begin
          ActiveRecord::Base.transaction do
            if params[:description].present?
              pricing_plan.description = params[:description].strip
            end

            if params[:internal_identifier].present?
              pricing_plan.internal_identifier = params[:internal_identifier].strip
            end

            if params[:external_identifier].present?
              pricing_plan.external_identifier = params[:external_identifier].strip
            end

            if params[:external_id_source].present?
              pricing_plan.external_id_source = params[:external_id_source].strip
            end

            if params[:comments].present?
              pricing_plan.comments = params[:comments].strip
            end

            if params[:from_date].present?
              pricing_plan.from_date = params[:from_date].to_date
            end

            if params[:thru_date].present?
              pricing_plan.thru_date = params[:thru_date].to_date
            end

            if params[:is_simple_amount].present?
              pricing_plan.is_simple_amount = params[:is_simple_amount]
            end

            if params[:currency_iid].present?
              pricing_plan.currency = Currency.find_by_internal_identifier(params[:currency_iid])
            end

            if params[:money_amount].present?
              pricing_plan.money_amount = params[:money_amount]
            end

            pricing_plan.save!

            render json: {success: true, pricing_plan: pricing_plan.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.error invalid.record.errors

          render :json => {:success => false, :message => invalid.record.errors}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Could not update PricingPlan'}
        end
      end

=begin

 @api {delete} /api/v1/pricing_plans/:id
 @apiVersion 1.0.0
 @apiName DestroyPricingPlan
 @apiGroup PricingPlan
 @apiDescription Destroy PricingPlan

 @apiParam (query) {Integer} id Id of PricingPlan

 @apiSuccess (200) {Object} destroy_pricing_plan_response Response.
 @apiSuccess (200) {Boolean} destroy_pricing_plan_response.success True if the request was successful

=end

      def destroy
        pricing_plan = PricingPlan.find(params[:id])

        pricing_plan.destroy

        render json: {success: true}
      end

    end # PricingPlansController
  end # V1
end # API
