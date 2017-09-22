module API
  module V1
    class ProductOffersController < BaseController

=begin

 @api {get} /api/v1/product_offers
 @apiVersion 1.0.0
 @apiName GetProductOffers
 @apiGroup ProductOffer
 @apiDescription Get Product Types

 @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
 @apiParam (query) {String} [query_filter] JSON string of data to filter by
 @apiParam (query) {String} [context] JSON string of data in regards to the context the api is being called, {"view": "mobile"}
 @apiParam (query) {String} [query] String to query the ProductOffers by

 @apiSuccess (200) {Object} get_product_offers_response Response.
 @apiSuccess (200) {Boolean} get_product_offers_response.success True if the request was successful
 @apiSuccess (200) {Number} get_product_offers_response.total_count Total count of ProductOffer records
 @apiSuccess (200) {Object[]} get_product_offers_response.product_offers List of ProductOffer records
 @apiSuccess (200) {Number} get_product_offers_response.product_offers.id Id of ProductOffer

=end


      def index
        sort = nil
        dir = nil
        limit = nil
        start = nil

        unless params[:sort].blank?
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'description'
          dir = sort_hash[:direction] || 'ASC'
          limit = params[:limit] || 25
          start = params[:start] || 0
        end

        query_filter = params[:query_filter].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:query_filter]))
        context = params[:context].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:context]))

        if params[:query]
          query_filter[:keyword] = params[:query].strip
        end

        # hook method to apply any scopes passed via parameters to this api
        product_offers = ProductOffer.apply_filters(query_filter)

        if sort and dir
          product_offers = product_offers.order("#{sort} #{dir}")
        end

        total_count = product_offers.count

        if start and limit
          product_offers = product_offers.offset(start).limit(limit)
        end

        product_offers = product_offers.order('description')

        if context[:view]
          if context[:view] == 'mobile'
            render :json => {success: true,
                             total_count: total_count,
                             product_offers: product_offers.collect { |product_offer| product_offer.to_mobile_hash }}
          end
        else
          render :json => {success: true,
                           total_count: total_count,
                           product_offers: product_offers.collect { |product_offer| product_offer.to_data_hash }}
        end

      end
=begin

 @api {get} /api/v1/product_offers/:id
 @apiVersion 1.0.0
 @apiName GetProductOffer
 @apiGroup ProductOffer
 @apiDescription Get Product Type

 @apiParam (query) {Integer} id Id of ProductOffer

 @apiSuccess (200) {Object} get_product_offer_response Response.
 @apiSuccess (200) {Boolean} get_product_offer_response.success True if the request was successful
 @apiSuccess (200) {Object} get_product_offers_response.product_offer ProductOffer record
 @apiSuccess (200) {Number} get_product_offers_response.product_offer.id Id of ProductOffer

=end


      def show
        product_offer = ProductOffer.find(params[:id])

        respond_to do |format|
          # if a tree format was requested then respond with the children of this ProductOffer
          format.tree do
            render :json => {success: true, product_offers: ProductOffer.where(parent_id: product_offer).order("sequence ASC").collect { |child| child.to_data_hash }}
          end

          # if a json format was requested then respond with the ProductOffer in json format
          format.json do
            render :json => {success: true, product_offer: product_offer.to_data_hash}
          end
        end

        render :json => {success: true,
                         product_offer: product_offer.to_data_hash}
      end

=begin

 @api {post} /api/v1/product_offers/
 @apiVersion 1.0.0
 @apiName CreateProductOffer
 @apiGroup ProductOffer
 @apiDescription Create Product Type

 @apiParam (body) {String} description Description
 @apiParam (body) {String} sku SKU to set
 @apiParam (body) {String} unit_of_masurement Internal Identifier of UnitOfMeasurement
 @apiParam (body) {String} [comment] Comment to set
 @apiParam (body) {String} [party_role] RoleType Internal Identifier to set for the passed party
 @apiParam (body) {Number} [party_id] Id of Party to associate to this ProductOffer, used to associate a Vendor to a ProductOffer for example
 @apiSuccess (200) {Object} create_product_offer_response Response.

 @apiSuccess (200) {Boolean} create_product_offer_response.success True if the request was successful
 @apiSuccess (200) {Object} create_product_offer_response.product_offer ProductOffer record
 @apiSuccess (200) {Number} create_product_offer_response.product_offer.id Id of ProductOffer

=end


      def create
        begin
          ActiveRecord::Base.transaction do
            product_offer = ProductOffer.new
            product_offer.description = params[:description]
            product_offer.sku = params[:sku]
            product_offer.unit_of_measurement_id = params[:unit_of_measurement]
            product_offer.comment = params[:comment]

            product_offer.created_by_party = current_user.party

            product_offer.save!

            #
            # For scoping by party, add party_id and role_type 'vendor' to product_party_roles table. However may want to override controller elsewhere
            # so that default is no scoping in erp_products engine
            #
            party_role = params[:party_role]
            party_id = params[:party_id]
            unless party_role.blank? or party_id.blank?
              product_offer_party_role = ProductOfferPtyRole.new
              product_offer_party_role.product_offer = product_offer
              product_offer_party_role.party_id = party_id
              product_offer_party_role.role_type = RoleType.iid(party_role)
              product_offer_party_role.save
            end
          end

          render :json => {success: true,
                           product_offer: product_offer.to_data_hash}

        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not create product type'}
        end
      end
=begin

 @api {put} /api/v1/product_offers/:id
 @apiVersion 1.0.0
 @apiName UpdateProductOffer
 @apiGroup ProductOffer
 @apiDescription Update Product Type

 @apiParam (query) {Integer} id Id of ProductOffer
 @apiParam (body) {String} [description] Description
 @apiParam (body) {String} [sku] SKU to set
 @apiParam (body) {String} [unit_of_masurement] Internal Identifier of UnitOfMeasurement
 @apiParam (body) {String} [comment] Comment to set

 @apiSuccess (200) {Object} update_product_offer_response Response.
 @apiSuccess (200) {Boolean} update_product_offer_response.success True if the request was successful
 @apiSuccess (200) {Object} update_product_offer_response.product_offer ProductOffer record
 @apiSuccess (200) {Number} update_product_offer_response.product_offer.id Id of ProductOffer

=end


      def update
        begin
          ActiveRecord::Base.transaction do
            product_offer = ProductOffer.find(params[:id])

            product_offer.description = params[:description]
            product_offer.sku = params[:sku]
            product_offer.unit_of_measurement_id = params[:unit_of_measurement]
            product_offer.comment = params[:comment]

            product_offer.updated_by_party = current_user.party

            product_offer.save!

            render :json => {success: true,
                             product_offer: product_offer.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.full_messages.join(', ')}

        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Could not update product type'}
        end
      end
=begin

 @api {delete} /api/v1/product_offers/:id
 @apiVersion 1.0.0
 @apiName DeleteProductOffer
 @apiGroup ProductOffer
 @apiDescription Delete Product Offer

 @apiParam (param) {Integer} id Id of record to delete

 @apiSuccess (200) {Object} delete_product_offer_response Response.
 @apiSuccess (200) {Boolean} delete_product_offer_response.success True if the request was successful

=end

      def destroy
        ProductOffer.find(params[:id]).destroy

        render :json => {:success => true}
      end

=begin

 @api {delete} /api/v1/product_offers/special_delete
 @apiVersion 1.0.0
 @apiName SpecialDeleteProductOffer
 @apiGroup ProductOffer
 @apiDescription Delete Product Offer

 @apiParam (param) {Integer} id Id of record to delete

 @apiSuccess (200) {Object} delete_product_offer_response Response.
 @apiSuccess (200) {Boolean} delete_product_offer_response.success True if the request was successful

=end

      def special_delete
        id = params[:id].to_i
        associated_product_is_base = params[:base_product] == 'true' ? true : false
        discount_id = params[:discount_id].to_i
        product_offer = ProductOffer.find(id.to_i)

        unless product_offer.nil?

          # if it's a base product, remove all of it's variant from the discount
          # if it's not a base just remove the offer
          # if it's the last variant for the product, remove the base too
          if associated_product_is_base
            product_type = ProductType.find(product_offer.product_type_id)
            product_variants = product_type.children
            product_variants.each do |product_variant|
              # see if there's a product offer for the variant
              variant_product_offer = ProductOffer.find_by_discount_id_and_product_type_id(discount_id, product_variant.id)
              unless variant_product_offer.nil?
                variant_product_offer.destroy
              end
            end
            product_offer.destroy
          else
            offer_product_type = ProductType.find(product_offer.product_type_id)
            if no_other_children_in_discount?(discount_id, offer_product_type, product_offer.product_type_id)
              # if there no other variants of this product type in the offer, delete the base too
              # find the the parent and delete it
              offer_product_type_parent = offer_product_type.parent
              parent_product_type_offer = ProductOffer.find_by_discount_id_and_product_type_id(discount_id, offer_product_type_parent.id)
              unless parent_product_type_offer.nil?
                parent_product_type_offer.destroy
              end
            end
            product_offer.destroy
          end
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end

      private

      def no_other_children_in_discount?(discount_id, offer_product_type, current_offer_product_type_id)
        offer_product_type_parent = offer_product_type.parent
        child_ids = offer_product_type_parent.children.collect { |children| children.id}
        child_ids.delete(current_offer_product_type_id)
        child_ids.each do |child_id|
          product_offer_for_child = ProductOffer.find_by_discount_id_and_product_type_id(discount_id, child_id)
          unless product_offer_for_child.nil?
            return false
          end
        end
        return true
      end

    end # ProductOffersController
  end # V1
end # API