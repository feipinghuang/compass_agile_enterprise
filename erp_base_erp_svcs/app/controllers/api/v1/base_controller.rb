module Api
  module V1
    class BaseController < ActionController::Base

      before_filter :require_login
      layout false

      protected

      def not_authenticated
        render json: {success: false, message: 'Not Authenticated'}
      end

      protected

      # hook method to apply any scopes passed via parameters to this API Controller
      #
      # @param statement [ActiveRecord::Relation] relation query being built for the record accessed via
      # this API
      # @return [ActiveRecord::Relation]
      def apply_scopes(statement)
        statement
      end

    end
  end # V1
end # Api

