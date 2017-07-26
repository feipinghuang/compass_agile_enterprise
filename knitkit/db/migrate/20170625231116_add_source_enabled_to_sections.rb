class AddSourceEnabledToSections < ActiveRecord::Migration
  def up
    unless column_exists? :website_sections, :source_enabled
      add_column :website_sections, :source_enabled, :boolean, default: false
    end
  end

  def down
    if column_exists? :website_sections, :source_enabled
      remove_column :website_sections, :source_enabled
    end
  end
end
