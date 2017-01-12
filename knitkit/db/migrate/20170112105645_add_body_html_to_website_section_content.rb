class AddBodyHtmlToWebsiteSectionContent < ActiveRecord::Migration
  def up

    unless column_exists? :website_section_contents, :body_html
      add_column :website_section_contents, :body_html, :text
    end

  end

  def down

    if column_exists? :website_section_contents, :body_html
      drop_column :website_section_contents, :body_html
    end

  end
end
