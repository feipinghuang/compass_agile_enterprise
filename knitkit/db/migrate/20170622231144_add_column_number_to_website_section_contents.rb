class AddColumnNumberToWebsiteSectionContents < ActiveRecord::Migration
  def up
    unless column_exists? :website_section_contents, :col
      add_column :website_section_contents, :col, :integer
    end
  end
  def down
    if column_exists? :website_section_contents, :col
      remove_column :website_section_contents, :col
    end
  end
end
