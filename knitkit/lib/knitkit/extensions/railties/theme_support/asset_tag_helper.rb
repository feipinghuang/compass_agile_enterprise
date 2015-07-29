# With http://github.com/rails/rails/commit/104898fcb7958bcb69ba0239d6de8aa37f2da9ba
# Rails edge (2.3) reverted all the nice oop changes that were introduced to
# asset_tag_helper in 2.2 ... so no point to code against the 2.2'ish API
# any more. Ok, let's instead overwrite everything. OMG ... suck, why does
# this so remind me of PHP.

require 'action_view/helpers/asset_tag_helper'

module ActionView
  module Helpers
    module AssetTagHelper

      def theme_javascript_path(theme, source)
        theme = controller.website.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)

        name, directory = name_and_path_from_source(source, "#{theme.url}/javascripts")

        file = theme.files.where('name = ? and directory = ?', name, directory).first

        file.nil? ? '' : file.data.url
      end

      alias_method :theme_path_to_javascript, :theme_javascript_path

      def theme_javascript_include_tag(theme_id, *sources)
        theme = controller.website.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        options = sources.extract_options!.stringify_keys
        cache = options.delete("cache")
        recursive = options.delete("recursive")

        sources = theme_expand_javascript_sources(theme, sources, recursive).collect do |source|
          theme_javascript_src_tag(theme, source, options)
        end.join("\n")
        raw sources
        #end
      end

      def theme_stylesheet_path(theme, source)
        theme = controller.website.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)

        name, directory = name_and_path_from_source(source, "#{theme.url}/stylesheets")

        file = theme.files.where('name = ? and directory = ?', name, directory).first

        file.nil? ? '' : file.data.url
      end

      alias_method :theme_path_to_stylesheet, :theme_stylesheet_path

      def theme_stylesheet_link_tag(theme_id, *sources)
        theme = controller.website.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        options = sources.extract_options!.stringify_keys
        cache = options.delete("cache")
        recursive = options.delete("recursive")

        sources = theme_expand_stylesheet_sources(theme, sources, recursive).collect do |source|
          theme_stylesheet_tag(theme, source, options)
        end.join("\n")
        raw sources
        #end
      end

      def theme_image_path(theme, source)
        theme = controller.website.themes.find_by_theme_id(theme) unless theme.is_a?(Theme)

        name, directory = name_and_path_from_source(source, "#{theme.url}/images")

        file = theme.files.where('name = ? and directory = ?', name, directory).first

        file.nil? ? '' : file.data.url
      end

      alias_method :theme_path_to_image, :theme_image_path # aliased to avoid conflicts with an image_path named route

      def theme_image_tag(theme_id, source, options = {})
        theme = controller.website.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        options.symbolize_keys!
        options[:src] = theme_path_to_image(theme, source)
        options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize

        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
        end

        if mouseover = options.delete(:mouseover)
          options[:onmouseover] = "this.src='#{theme_image_path(theme, mouseover)}'"
          options[:onmouseout] = "this.src='#{theme_image_path(theme, options[:src])}'"
        end

        tag("img", options)
      end

      # theme_font_include(theme_id, font_file_name, options={})
      # @param1: theme_id(string)
      # @param2: font_file_name(string)
      # @param3: options = {
      #                       sources: [
      #                                   {url: 'font1', format: 'format1'},
      #                                   {url: 'font2', format: 'format2'}
      #                                ],
      #                                font_family: 'FontFamilyName',
      #                                font_style: normal,
      #                                font_weight: normal,
      #                                font_stretch: '',
      #                                unicode_range: '',
      #                                apply_to: ''           # by default to body
      #                     }
      def theme_font_include(theme_id, font_file_name, options={})
        theme = controller.website.themes.find_by_theme_id(theme_id)
        return("could not find theme with the id #{theme_id}") unless theme

        theme_font_src_tag(theme, font_file_name, options)
      end

      private

      def theme_font_path(theme, font_file_name)
        name, directory = name_and_path_from_source(font_file_name, "#{theme.url}/fonts")
        file = theme.files.where('name = ? and directory = ?', name, directory).first
        file.nil? ? '' : file.data.url
      end

      def get_theme_font_urls(path, sources)
        font_urls = []
        sources.each do |source|
          url_str = "url('#{path + source[:url]}') format('#{source[:format]}')"
          font_urls << url_str
        end
        font_urls
      end

      def get_theme_attributes(path, options)
        font_options = {}
        font_options['src'] = get_theme_font_urls(path, options[:sources]).join(',') if options[:sources]

        %w(font-family font-weight font-style font-stretch unicode-range).each do |option_key|
          key = option_key.split('-').join('_')

          if option_key == 'font_family'
            font_options[option_key] = "'#{options[key.to_sym]}'"
          else
            font_options[option_key] = options[key.to_sym]
          end if options[key.to_sym].present?
        end

        font_options
      end

      def generate_font_css_code(url, options, apply_to)
        font_code = "@font-face{\n src: url('#{url}'); \n"

        options.each do |key, value|
          font_code += "#{key}: #{value}; \n"
        end
        font_code += '}'

        apply_to ||= 'body'
        font_code += "\n#{apply_to}{ font-family: #{options['font-family']} !important;}"

        font_code
      end

      def theme_font_src_tag(theme, font_file_name, options)
        font_url = theme_font_path(theme, font_file_name)
        font_code = ""

        if font_url.present?
          absolute_path = font_url.split(font_file_name).first
          font_options = get_theme_attributes(absolute_path, options)
          font_code = generate_font_css_code(font_url, font_options, options[:apply_to])
        end

        content_tag("style", raw(font_code))
      end

      def theme_compute_public_path(theme, source, dir, ext = nil, include_host = true)
        has_request = controller.respond_to?(:request)

        if ext && (File.extname(source).blank? || File.exist?(File.join(theme.path, dir, "#{source}.#{ext}")))
          source += ".#{ext}"
        end

        unless source =~ %r{^[-a-z]+://}
          source = "/#{dir}/#{source}" unless source[0] == ?/

          source = theme_rewrite_asset_path(theme, source)

          if has_request && include_host
            unless source =~ %r{^#{ActionController::Base.config.relative_url_root}/}
              source = "#{ActionController::Base.config.relative_url_root}#{source}"
            end
          end
        end

        source
      end

      def theme_rails_asset_id(theme, source)
        if asset_id = ENV["RAILS_ASSET_ID"]
          asset_id
        else
          path = File.join(theme.path, source)
          asset_id = File.exist?(path) ? File.mtime(path).to_i.to_s : ''
          asset_id
        end
      end

      def theme_rewrite_asset_path(theme, source)
        asset_id = theme_rails_asset_id(theme, source)
        if asset_id.blank?
          source
        else
          source + "?#{asset_id}"
        end
      end

      def theme_javascript_src_tag(theme, source, options)
        options = {"type" => Mime::JS, "src" => theme_path_to_javascript(theme, source)}.merge(options)
        content_tag("script", "", options)
      end

      def theme_stylesheet_tag(theme, source, options)
        options = {"rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen",
                   "href" => html_escape(theme_path_to_stylesheet(theme, source))}.merge(options)
        tag("link", options, false, false)
      end

      def theme_compute_javascript_paths(theme, *args)
        theme_expand_javascript_sources(theme, *args).collect do |source|
          theme_compute_public_path(theme, source, theme.url + '/javascripts', 'js', false)
        end
      end

      def theme_compute_stylesheet_paths(theme, *args)
        theme_expand_stylesheet_sources(theme, *args).collect do |source|
          theme_compute_public_path(theme, source, theme.url + '/stylesheets', 'css', false)
        end
      end

      def theme_expand_javascript_sources(theme, sources, recursive = false)
        if sources.include?(:all)
          all_javascript_files = collect_asset_files(theme.path + '/javascripts', ('**' if recursive), '*.js').uniq
        else
          sources.flatten
        end
      end

      def theme_expand_stylesheet_sources(theme, sources, recursive)
        if sources.first == :all
          collect_asset_files(theme.path + '/stylesheets', ('**' if recursive), '*.css')
        else
          sources.flatten
        end
      end

      def theme_write_asset_file_contents(theme, joined_asset_path, asset_paths)
        FileUtils.mkdir_p(File.dirname(joined_asset_path))
        File.open(joined_asset_path, "w+") do |cache|
          cache.write(theme_join_asset_file_contents(theme, asset_paths))
        end
        mt = asset_paths.map { |p| File.mtime(theme_asset_file_path(theme, p)) }.max
        File.utime(mt, mt, joined_asset_path)
      end

      def theme_join_asset_file_contents(theme, paths)
        paths.collect { |path| File.read(theme_asset_file_path(theme, path)) }.join("\n\n")
      end

      def theme_asset_file_path(theme, path)
        File.join(Theme.root_dir, path.split('?').first)
      end

      def name_and_path_from_source(source, base_directory)
        path = source.split('/')
        name = path.last

        directory = if path.length > 1
                      #remove last element
                      path.pop

                      "#{base_directory}/#{path.join('/')}"
                    else
                      base_directory
                    end

        return name, directory
      end

    end # AssetTagHelper
  end # Helpers
end # ActionView