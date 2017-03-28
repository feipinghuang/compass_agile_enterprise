class AddBuilderHtmlAndWebsiteHtmltoWebsiteContentSections < ActiveRecord::Migration
  def up
    if column_exists? :website_section_contents, :body_html
      rename_column :website_section_contents, :body_html, :builder_html
    end
    unless column_exists? :website_section_contents, :website_html
      add_column :website_section_contents, :website_html
    end
  end
  
  def down
    if column_exists? :website_section_contents, :builder_html
      rename_column :website_section_contents, :builder_html, :body_html
    end
    if column_exists? :website_section_contents, :website_html
      remove_column :website_section_contents, :website_html
    end
  end
end
