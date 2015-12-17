module Api
  module V1
    class ProductTypesController < BaseController

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

        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        # hook method to apply any scopes passed via parameters to this api
        product_types = ProductType.apply_filters(query_filter)

        # scope by dba_organizations if there are no parties passed as filters
        unless query_filter[:parties]
          dba_organizations = [current_user.party.dba_organization]
          dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
          product_types = product_types.scope_by_dba_organization(dba_organizations)
        end

        if sort and dir
          product_types = product_types.order("#{sort} #{dir}")
        end

        total_count = product_types.count

        if start and limit
          product_types = product_types.offset(start).limit(limit)
        end

        render :json => {success: true,
                         total_count: total_count,
                         product_types: product_types.collect { |product_type| product_type.to_data_hash }}

      end

      def show
        product_type = ProductType.find(params[:id])

        render :json => {success: true,
                         product_type: product_type.to_data_hash}
      end

      def create

        product_type = ProductType.new
        product_type.description = params[:description]
        product_type.sku = params[:sku]
        product_type.unit_of_measurement_id = params[:unit_of_measurement]
        product_type.comment = params[:comment]
        product_type.save

        #
        # For scoping by party, add party_id and role_type 'vendor' to product_party_roles table. However may want to override controller elsewhere
        # so that default is no scoping in erp_products engine
        #
        party_role = params[:party_role]
        party_id = params[:party_id]
        unless party_role.blank? or party_id.blank?
          product_type_party_role = ProductTypePtyRole.new
          product_type_party_role.product_type = product_type
          product_type_party_role.party_id = party_id
          product_type_party_role.role_type = RoleType.iid(party_role)
          product_type_party_role.save
        end

        render :json => {success: true,
                         product_type: product_type.to_data_hash}
      end

      def update
        product_type = ProductType.find(params[:id])

        product_type.description = params[:description]
        product_type.sku = params[:sku]
        product_type.unit_of_measurement_id = params[:unit_of_measurement]
        product_type.comment = params[:comment]
        product_type.save

        render :json => {success: true,
                         product_type: product_type.to_data_hash}

      end

      def destroy
        ProductType.find(params[:id]).destroy

        render :json => {:success => true}

      end

    end # ProductTypesController
  end # V1
end # Api