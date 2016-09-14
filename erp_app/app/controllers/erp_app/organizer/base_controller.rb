module ErpApp
  module Organizer
    class BaseController < ErpApp::ApplicationController
      layout nil
      before_filter :require_login

      def index
        @user = current_user
      end

    end # BaseController
  end # Organizer
end # ErpApp
