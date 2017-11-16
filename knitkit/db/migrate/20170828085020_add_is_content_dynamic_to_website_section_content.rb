class AddIsContentDynamicToWebsiteSectionContent < ActiveRecord::Migration
  def up
    unless column_exists? :website_section_contents, :is_content_dynamic
      add_column :website_section_contents, :is_content_dynamic, :boolean
    end
  end

  def down
    if column_exists? :website_section_contents, :is_content_dynamic
      remove_column :website_section_contents, :is_content_dynamic
    end
  end
end
