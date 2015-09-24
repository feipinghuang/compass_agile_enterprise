module RailsDbAdmin
  module Extensions
    module ActionController
      module ReportSupport
        class Cache
          cattr_accessor :report_resolvers
        end
        module ActsAsReportController
          def self.included(base)
            base.class_eval do
              extend ActMacro
              delegate :acts_as_report_controller?, :to => "self.class"
            end
          end

          module ActMacro
            def acts_as_report_controller(options = {})
              before_filter :add_report_view_paths

              return if acts_as_report_controller?
              include InstanceMethods
            end

            def acts_as_report_controller?
              included_modules.include?(InstanceMethods)
            end
          end

          module InstanceMethods

            def add_report_view_paths
              ReportSupport::Cache.report_resolvers = [] if ReportSupport::Cache.report_resolvers.nil?
              if respond_to?(:current_report_path)
                report_path = current_report_path
                resolver = case Rails.application.config.erp_tech_svcs.file_storage
                             when :s3
                               path = File.join(report_path[:url], "templates")
                               cached_resolver = ReportSupport::Cache.report_resolvers.find { |cached_resolver| cached_resolver.to_path == path }
                               if cached_resolver.nil?
                                 resolver = ActionView::S3Resolver.new(path)
                                 ReportSupport::Cache.report_resolvers << resolver
                                 resolver
                               else
                                 cached_resolver
                               end
                             when :filesystem
                               path = "#{report_path[:path]}/templates"
                               cached_resolver = ReportSupport::Cache.report_resolvers.find { |cached_resolver| cached_resolver.to_path == path }
                               if cached_resolver.nil?
                                 resolver = ActionView::ThemeFileResolver.new(path)
                                 ReportSupport::Cache.report_resolvers << resolver
                                 resolver
                               else
                                 cached_resolver
                               end
                           end
                prepend_view_path(resolver)
              end
            end

            def current_report_path
              {:url => @report.url.to_s, :path => @report.base_dir.to_s}
            end

          end #InstanceMethods
        end #ActsAsReportController
      end #ReportSupport
    end #ActionController
  end #Extensions
end #RailsDbAdmin
