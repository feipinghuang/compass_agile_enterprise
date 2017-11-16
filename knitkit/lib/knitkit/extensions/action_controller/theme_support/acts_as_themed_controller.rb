module Knitkit
  module Extensions
    module ActionController
      module ThemeSupport
        class Cache
          cattr_accessor :theme_resolvers
        end
        module ActsAsThemedController
          def self.included(base)
            base.class_eval do
              extend ActMacro
              delegate :acts_as_themed_controller?, :to => "self.class"
            end
          end

          module ActMacro
            def acts_as_themed_controller(options = {})
              generate_is_website_builder_method(options[:website_builder])
              before_filter :add_theme_view_paths
              return if acts_as_themed_controller?
              include InstanceMethods
            end

            def acts_as_themed_controller?
              included_modules.include?(InstanceMethods)
            end

            def generate_is_website_builder_method(is_website_builder)
              unless method_defined?(:is_website_builder?)
                define_method(:is_website_builder?) { is_website_builder }
              end
            end

          end

          module InstanceMethods
            def current_themes
              # the lambda broke in rails 3.2, changing this to an instance variable
              # if website_builder options is true, add all themes irrespective of their active status
              if is_website_builder?
                @current_themes ||= self.website.themes.compact rescue []
              else
                @current_themes ||= self.website.themes.collect{|t| t if t.active == 1}.compact rescue []
              end
              # @current_themes ||= case accessor = self.class.read_inheritable_attribute(:current_themes)
              # when Symbol then accessor == :current_themes ? raise("screwed") : send(accessor)
              # when Proc   then accessor.call(self)
              # else accessor
              # end
            end

            def add_theme_view_paths
              ThemeSupport::Cache.theme_resolvers = [] if ThemeSupport::Cache.theme_resolvers.nil?
              if respond_to?(:current_theme_paths)
                current_theme_paths.each do |theme|
                  resolver = case Rails.application.config.erp_tech_svcs.file_storage
                               when :s3
                                 path = File.join(theme[:url], "templates")
                                 cached_resolver = ThemeSupport::Cache.theme_resolvers.find { |cached_resolver| cached_resolver.to_path == path }
                                 if cached_resolver.nil?
                                   resolver = ActionView::S3Resolver.new(path)
                                   ThemeSupport::Cache.theme_resolvers << resolver
                                   resolver
                                 else
                                   cached_resolver
                                 end
                               when :filesystem
                                 path = "#{theme[:path]}/templates"
                                 cached_resolver = ThemeSupport::Cache.theme_resolvers.find { |cached_resolver| cached_resolver.to_path == path }
                                 if cached_resolver.nil?
                                   resolver = ActionView::CompassAeFileResolver.new(path)
                                   ThemeSupport::Cache.theme_resolvers << resolver
                                   resolver
                                 else
                                   cached_resolver
                                 end
                             end
                  prepend_view_path(resolver)
                end
              end
            end

            def current_theme_paths
              current_themes ? current_themes.map { |theme| {:path => theme.path.to_s, :url => theme.url.to_s} } : []
            end

            def authorize_template_extension!(template, ext)
              return if allowed_template_type?(ext)
              raise ThemeSupport::TemplateTypeError.new(template, force_template_types)
            end

            def allowed_template_type?(ext)
              force_template_types.blank? || force_template_types.include?(ext)
            end
          end #InstanceMethods
        end #ActsAsThemedController
      end #ThemeSupport
    end #ActionController
  end #Extensions
end #Knitkit
