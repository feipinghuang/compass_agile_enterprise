module ErpApp
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module RemoteTagHelper

            def link_to_remote(name, url, options={})
              #add ajax_replace class
              options[:class].nil? ? 'ajax_replace' : "#{options[:class]} ajax_replace"
              #add remote => true to options
              options.merge!({:remote => true})
              link_to name, url, options
            end

            def form_remote_tag(url, options={}, &block)
              #add ajax_replace class
              options[:class].nil? ? 'ajax_replace' : "#{options[:class]} ajax_replace"
              #add remote => true to options
              options.merge!({:remote => true})

              if block_given?
                form_tag url, options do
                  yield
                end
              else
                form_tag url, options
              end
            end

          end # RemoteTagHelper
        end # Helpers
      end # ActionView
    end # Railties
  end # Extensions
end # ErpApp
