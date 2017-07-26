class AddMetaDataToThemes < ActiveRecord::Migration
  def up
    unless column_exists? :themes, :meta_data
      add_column :themes, :meta_data, :text
    end
  end

  def down
    if column_exists? :themes, :meta_data
      drop_column :themes, :meta_data
    end
  end
end
