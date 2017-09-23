module CompassAeSencha
  class Engine < Rails::Engine
    isolate_namespace CompassAeSencha

    Mime::Type.register "ext_js", :ext_js

    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "images")
      Rails.application.config.assets.precompile += %w{ extjs/app.js sencha_touch/app.js extjs/Callout.js }
      Rails.application.config.assets.precompile += %w{ extjs/resources/css/compass-ae-default-all.css extjs/resources/css/callout-default.css sencha_touch/app.css }
    end
  end
end
