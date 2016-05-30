#require all ActionView helper files
Dir.entries(File.join(File.dirname(__FILE__),"helpers")).delete_if{|name| name =~ /^\./}.each do |file|
  require "erp_app/extensions/railties/action_view/helpers/#{file}"
end

ActionView::Base.class_eval do
  include ErpApp::Extensions::Railties::ActionView::Helpers::IncludeHelper
end

ActionView::Helpers::TagHelper.class_eval do
  include ErpApp::Extensions::Railties::ActionView::Helpers::RemoteTagHelper
end
