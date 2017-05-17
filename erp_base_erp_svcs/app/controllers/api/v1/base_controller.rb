module API
  module V1
    class BaseController < ActionController::Base

      class ApiError < StandardError; end

      before_filter :require_login
      before_filter :set_paging
      before_filter :set_query_filters
      layout false

      protected

      def not_authenticated
        render json: {success: false, message: 'Not Authenticated'}, status: 401
      end

      def set_paging
        @offset = params[:offset] || params[:start] || 0
        @limit = params[:limit] || 25
      end

      def set_query_filters
        @query_filter = params[:query_filter].blank? ? {} : JSON.parse(params[:query_filter]).symbolize_keys
      end

    end
  end # V1
end # API
