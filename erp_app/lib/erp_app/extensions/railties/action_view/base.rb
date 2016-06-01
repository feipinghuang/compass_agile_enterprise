require "erp_app/extensions/railties/action_view/helpers/include_helper"

ActionView::Base.class_eval do
  include ErpApp::Extensions::Railties::ActionView::Helpers::IncludeHelper
end

ActionView::Helpers::FormTagHelper.class_eval do

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

end

ActionView::Helpers::TagHelper.class_eval do

  def link_to_remote(name, url, options={})
    #add ajax_replace class
    options[:class].nil? ? 'ajax_replace' : "#{options[:class]} ajax_replace"
    #add remote => true to options
    options.merge!({:remote => true})
    link_to name, url, options
  end

end
