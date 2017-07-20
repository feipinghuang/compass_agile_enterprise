class AddBuilderHtmlAndWebsiteHtmlToWebsiteSectionContents < ActiveRecord::Migration
  def up
    unless column_exists? :website_section_contents, :builder_html
      add_column :website_section_contents, :builder_html, :text
    end

    if column_exists? :website_section_contents, :body_html
      rename_column :website_section_contents, :body_html, :website_html
    end
    
  end

  def down
    if column_exists? :website_section_contents, :builder_html
      drop_column :website_section_contents, :builder_html
    end

    if column_exists? :website_section_contents, :website_html
      rename_column :website_section_contents, :website_html, :body_html
    end
    
  end
end
