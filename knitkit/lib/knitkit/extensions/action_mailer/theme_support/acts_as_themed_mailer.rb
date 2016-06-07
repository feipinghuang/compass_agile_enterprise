module Knitkit
  module Extensions
    module ActionMailer
      module ThemeSupport
        class Cache
          cattr_accessor :theme_resolvers
        end
        module ActsAsThemedMailer
          def self.included(base)
            base.class_eval do
              extend ActMacro
            end
          end

          module ActMacro
            def acts_as_themed_mailer
              include InstanceMethods
            end
          end

          module InstanceMethods
            def add_theme_view_paths(website)
              ThemeSupport::Cache.theme_resolvers = [] if ThemeSupport::Cache.theme_resolvers.nil?
              current_theme_paths(website).each do |theme|
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

            def current_theme_paths(website)
              website.nil? ? [] : website.themes.active.map { |theme| {:path => theme.path.to_s, :url => theme.url.to_s} }
            end

          end #InstanceMethods
        end #ActsAsThemedMailer
      end #ThemeSupport
    end #ActionMailer
  end #Extensions
end #Knitkit