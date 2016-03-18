
# == Basic overview
# Based on ideas and code snippits from Cell plugin this library allows you
# to embed a reusable component into view that is decoupled from the controller
# and view it resides in. It can have its own MVC lifecycle independent of its parent
# view.

require 'abstract_controller'
require 'action_controller'

module ErpApp
  module Widgets
    class Base < ActionController::Metal
      abstract!

      include AbstractController
      include Rendering, Layouts, Helpers, Callbacks, Translation, Logger
      include ActionController::RequestForgeryProtection
      include ActionController::DataStreaming
      include ActionController::Streaming

      IGNORED_PARAMS = %w{action controller uuid widget_name widget_action dynamic_form_id dynamic_form_model_id
                          model_name use_dynamic_form authenticity_token is_html_form commit utf8}

      delegate :redirect_to, :config, :params, :session, :request, :logger, :logged_in?, :current_user, :login,
               :flash, :update_div_id, :update_html, :current_theme_paths, :request, :cookies, :to => :proxy_controller

      attr_reader   :state_name
      attr_accessor :proxy_controller, :name, :div_id,:html, :view, :uuid, :widget_params
      cattr_accessor :view_resolver_cache

      def initialize(proxy_controller=nil, name=nil, view=nil, uuid=nil, widget_params=nil)
        ErpApp::Widgets::Base.view_resolver_cache = [] if ErpApp::Widgets::Base.view_resolver_cache.nil?
        self.name = name
        self.proxy_controller = proxy_controller
        self.view = view
        self.uuid = uuid
        self.widget_params = widget_params
        add_view_paths
        store_widget_params
        merge_params
      end

      #override default behavior of nesting views by controller namespace....
      # The prefixes used in render "foo" shortcuts.
      def _prefixes
        @_prefixes ||= []
      end

      def widget_result_id
        "#{self.uuid}_result"
      end

      def render(*args)
        render_view_for(self.action_name, *args)
      end

      protected
      #get location of this class that is being executed
      def locate
        File.dirname(__FILE__)
      end

      #get the full file path for a view file relative to the widgets view path
      def get_views_full_path(view)
        self.lookup_context.find_template(view).virtual_path
      end

      def send_file(path, options = {})
        proxy_controller.send_file(path, options)

       {send_file: true}
      end

      def send_data(data, options = {})
        proxy_controller.send_data(data, options)

        {send_data: true}
      end

      def redirect_to(options = {}, response_status = {})
        proxy_controller.redirect_to(options, response_status)

        {redirect_to: true}
      end

      private

      def render_view_for(view, *args)
        opts = args.first.is_a?(::Hash) ? args.shift : {}

        return "" if opts[:nothing]

        if opts[:update]
          update_opts = opts[:update]
          if update_opts[:text]
            js = update_opts[:text]
          else
            opts = {:view => update_opts[:view]}
            process_opts_for(opts, view)
            js = render_to_string(opts).html_safe
          end
          extra_params = update_opts[:extraParams] || {}
          return {:json => {:htmlId => update_opts[:id], :html => js, :success => true, :extraParams => extra_params}}
        elsif (opts.keys & [:text, :inline, :file]).blank?
          process_opts_for(opts, view)
          return render_to_string(opts).html_safe # ActionView::Template::Text doesn't do that for us.
        else
          return opts
        end
      end

      def process_opts_for(opts, view)
        opts[:action] = opts[:view] || view
      end

      def merge_params
        stored_widget_params = session[:widgets][self.uuid]
        unless stored_widget_params.nil?
          self.params.merge! stored_widget_params.merge self.params
        end
      end

      def store_widget_params
        session[:widgets] = {} if session[:widgets].nil?
        session[:widgets][self.uuid] = self.widget_params if (!self.widget_params.nil? and !self.widget_params.empty?)
      end

      def add_view_paths
        widget = Rails.application.config.erp_app.widgets.find{|item| item[:name] == self.name}

        widget[:view_paths].each do |view_path|
          cached_resolver = ErpApp::Widgets::Base.view_resolver_cache.find{|resolver| resolver.to_path == view_path}
          if cached_resolver.nil?
            resolver = ActionView::OptimizedFileSystemResolver.new(view_path)
            prepend_view_path(resolver)
            ErpApp::Widgets::Base.view_resolver_cache << resolver
          else
            prepend_view_path(cached_resolver)
          end
        end
      end

      class << self
        def render_template(view, locals={})
          widget = Rails.application.config.erp_app.widgets.find{|item| item[:name] == self.widget_name}
          paths = widget[:view_paths]

          ActionView::Base.new(paths).render(:template => view, :locals => locals)
        end

        def widget_name
          File.basename(File.dirname(__FILE__))
        end

        def installed_widgets
          self.locate_widgets
        end

        private

        def locate_widgets
          widgets = []
          #get all widgets in root
          widget_path = File.join(Rails.root.to_s,"/app/widgets/")
          widgets = widgets | Dir.entries(widget_path) if File.exists? widget_path

          #get all widgets in engines
          Rails::Application::Railties.engines.each do |engine|
            #exclude widgets path in erp_app it defines are widgets
            next if engine.engine_name == "erp_app"
            widget_path = File.join(engine.root.to_s,"/app/widgets/")
            widgets = widgets | Dir.entries(widget_path) if File.exists? widget_path
          end
          #remove .svn .git etc files
          widgets.delete_if{|name| name =~ /^\./}
          widgets
        end
      end

    end#Base
  end#Widgets
end#ErpApp
