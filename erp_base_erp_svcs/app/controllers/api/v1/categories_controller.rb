module API
  module V1
    class CategoriesController < BaseController

=begin
 @api {get} /api/v1/categories
 @apiVersion 1.0.0
 @apiName GetCategories
 @apiGroup Category
 @apiDescription Get Categories

 @apiParam (query) {String} [sort] JSON string of date to control sorting {"property":"description", "direction":"ASC", "limit": 25, "start": 0}
 @apiParam (query) {String} [query_filter] JSON string of data to filter by
 @apiParam (query) {Integer} [parent_id] Id of parent category to filter by
 @apiParam (query) {Integer} [start] Start to for paging, defaults to 0
 @apiParam (query) {Integer} [limit] Limit to for paging, defaults to 25

 @apiSuccess (200) {Object} get_categories_response Response.
 @apiSuccess (200) {Boolean} get_categories_response.success True if the request was successful
 @apiSuccess (200) {Number} get_categories_response.total_count Total count of ProductType records
 @apiSuccess (200) {Object[]} get_categories_response.categories Array of Category records
 @apiSuccess (200) {Number} get_categories_response.categories.id Id of Category

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

        query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys

        if params[:parent_id]
          query_filter[:parent_id] = params[:parent_id]
        end

        # hook method to apply any scopes passed via parameters to this api
        categories = Category.apply_filters(query_filter)

        # scope by dba_organizations if there are no parties passed as filters
        dba_organizations = [current_user.party.dba_organization]
        dba_organizations = dba_organizations.concat(current_user.party.dba_organization.child_dba_organizations)
        categories = categories.by_tenant(dba_organizations)

        if query_filter[:with_products]
          categories = categories.where(categories: {id: Category.with_products(dba_organizations)})
        end

        respond_to do |format|
          format.json do

            if sort and dir
              categories = categories.except(:order).order("#{sort} #{dir}")
            end

            total_count = categories.count

            if start and limit
              categories = categories.offset(start).limit(limit)
            end

            render :json => {success: true,
                             total_count: total_count,
                             categories: categories.collect { |item| item.to_data_hash }}
          end
          format.tree do

            if params[:parent_id]
              render :json => {success: true,
                               categories: Category.find(params[:parent_id]).children_to_tree_hash({child_ids: categories})}
            else
              nodes = [].tap do |nodes|
                categories.roots.except(:order).order("#{sort} #{dir}").each do |root|
                  nodes.push(root.to_tree_hash)
                end
              end

              render :json => {success: true,
                               categories: nodes}
            end

          end
          format.all_representation do

            total_count = categories.count

            if start and limit
              categories = categories.offset(start).limit(limit)
            end

            if params[:parent_id].present?
              render :json => {success: true,
                               total_count: total_count,
                               categories: Category.to_all_representation(Category.find(params[:parent_id]))}, content_type: 'application/json'
            else


              render :json => {success: true,
                               total_count: total_count,
                               categories: Category.to_all_representation(nil, [], 0, categories.roots)}, content_type: 'application/json'
            end
          end
        end
      end

=begin

 @api {get} /api/v1/categories/:id
 @apiVersion 1.0.0
 @apiName GetCategory
 @apiGroup Category
 @apiDescription Get Category

 @apiParam (path) {Integer} id Id of Category

 @apiSuccess (200) {Object} get_category_response Response.
 @apiSuccess (200) {Boolean} get_category_response.success True if the request was successful
 @apiSuccess (200) {Object} get_category_response.category Category record
 @apiSuccess (200) {Number} get_category_response.category.id Id of Category

=end

      def show
        category = Category.find(params[:id])

        render json: {category: category.to_data_hash}
      end

=begin

 @api {post} /api/v1/categories/
 @apiVersion 1.0.0
 @apiName CreateCategory
 @apiGroup Category
 @apiDescription Create Category

 @apiParam (body) {Integer} [parent_id] Id of Parent Category
 @apiParam (body) {String} [internal_identifier] Internal Identifier for the category, if one is not passed one will be generated 
 @apiParam (body) {String} description Description Category

 @apiSuccess (200) {Object} create_category_response Response.
 @apiSuccess (200) {Boolean} create_category_response.success True if the request was successful
 @apiSuccess (200) {Object} create_category_response.category Category record
 @apiSuccess (200) {Number} create_category_response.category.id Id of Category

=end

      def create
        parent_id = params[:parent_id]

        begin
          ActiveRecord::Base.transaction do
            category = Category.new(
              description: params[:description].strip

            )

            if params[:internal_identifier].present?
              category.internal_identifier = params[:internal_identifier].strip
            else
              category.internal_identifier = Category.generate_unique_iid(params[:description].strip)
            end

            category.save!

            if parent_id and parent_id != 'No Parent'
              parent = Category.find(parent_id)
              if parent
                category.move_to_child_of(parent)
              end
            end

            category.set_tenant!(current_user.party.dba_organization)

            render json: {success: true, category: category.to_data_hash}
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

 @api {put} /api/v1/categories/:id
 @apiVersion 1.0.0
 @apiName UpdateCategory
 @apiGroup Category
 @apiDescription Update Category

 @apiParam (path) {Integer} id Id of Category

 @apiParam (body) {String} [internal_identifier] Internal Identifier to set for the Category.
 @apiParam (body) {String} [description] Description to set for the Category

 @apiSuccess (200) {Object} update_category_response Response.
 @apiSuccess (200) {Boolean} update_category_response.success True if the request was successful
 @apiSuccess (200) {Object} update_category_response.category Category record
 @apiSuccess (200) {Number} update_category_response.category.id Id of Category

=end

      def update
        category = Category.find(params[:id])

        begin
          ActiveRecord::Base.transaction do
            if params[:description].present?
              category.description = params[:description].strip
            end

            if params[:internal_identifier].present?
              category.internal_identifier = params[:internal_identifier].strip
            end

            category.save!

            render json: {success: true, category: category.to_data_hash}
          end
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render json: {success: false, message: 'Application Error'}
        end
      end

=begin

 @api {delete} /api/v1/categories/:id
 @apiVersion 1.0.0
 @apiName DestroyCategory
 @apiGroup Category
 @apiDescription Destroy Category

 @apiParam (path) {Integer} id Id of Category

 @apiSuccess (200) {Object} destroy_category_response Response.
 @apiSuccess (200) {Boolean} destroy_category_response.success True if the request was successful

=end

      def destroy
        category = Category.find(params[:id])

        category.destroy

        render json: {success: true}
      end

    end # CategoriesController
  end # V1
end # API
