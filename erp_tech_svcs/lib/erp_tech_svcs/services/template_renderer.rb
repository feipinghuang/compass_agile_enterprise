module ErpTechSvcs
  class TemplateRenderer < AbstractController::Base
    include AbstractController::Rendering
    include AbstractController::Layouts
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths

    def initialize(view_paths)
      self.class.view_paths = view_paths
    end

  end # TemplateRenderer
end # ErpTechSvcs
