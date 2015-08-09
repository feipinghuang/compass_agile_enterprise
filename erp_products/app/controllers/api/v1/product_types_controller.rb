module Api
  module V1
    class ProductTypesController < BaseController

      def index

        party_id = params[:party_id]
        party_role = params[:party_role]

        #
        # Get all product types
        #
        product_types = ProductType.order('created_at asc')

        #
        # Scope by party id and/or party role if specified
        #
        unless party_id.blank? and party_role.blank?

          product_types = product_types.joins(:product_type_pty_roles)
          product_types = product_types.where('product_type_pty_roles.party_id = ?', party_id) unless party_id.blank?

          unless party_role.blank?
            role_type = RoleType.iid(party_role)
            product_types = product_types.where('product_type_pty_roles.role_type_id = ?', role_type)
          end
        end

        total = product_types.count

        render :json => {:success => true, :total => total, :product_types => product_types.collect { |product_type| product_type.to_data_hash }}

      end

      def show

        product_type = ProductType.find(params[:product_type_id])

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