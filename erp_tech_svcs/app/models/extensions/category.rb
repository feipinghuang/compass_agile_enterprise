Category.instance_eval do
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_file_assets
end
