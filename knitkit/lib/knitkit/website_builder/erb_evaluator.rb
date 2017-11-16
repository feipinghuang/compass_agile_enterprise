# Evaluates ERB template contents on the fly
module Knitkit
  module WebsiteBuilder
    class ErbEvaluator
      class << self
        # evalute ERB contents
        # @param erb_string [String] ERB string
        # @param controller [ActionController::Base] The controller which provides context to evaulate
        # if this isn't passed the ERB will be evaluated in the context of ActionView::Base
        def evaluate(erb_string, controller = nil)
          # instantiate ActionView
          view_helper = ActionView::Base.new
          # if there is a controller, include it in the action view
          if controller
            # we don't want to modify the current controller which
            # servers the request, so dup and set its format to :html
            # as we want it to evaluate the passed in ERB string
            duped_controller = controller.dup
            duped_controller.env["action_dispatch.request.formats"] = [Mime::Type.lookup_by_extension(:html)]
            view_helper.controller = duped_controller
          end
          # get the action view context
          context = view_helper.instance_eval { binding }
          # evaluate ERB string with the above context
          source = ERB.new(erb_string).result(context)
          # deference every thing to garbage collect and prevent a possible
          # memory leak 
          duped_controller = nil
          context = nil
          view_helper = nil
          # return the evaluted ERB as string
          source
        end
      end
    end
  end
end
