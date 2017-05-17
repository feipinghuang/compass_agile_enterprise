module Knitkit
  module WebsiteBuilder
    class ErbEvaluator
      class << self
        def evaluate(erb_string, controller = nil)
          view_helper = ActionView::Base.new
          if controller
            duped_controller = controller.dup
            duped_controller.env["action_dispatch.request.formats"] = [Mime::Type.lookup_by_extension(:html)]
            view_helper.controller = duped_controller
          end
          context = view_helper.instance_eval { binding }
          source = ERB.new(erb_string).result(context)
          duped_controller = nil
          context = nil
          view_helper = nil
          source
        end
      end
    end
  end
end
