class AddCustomDataToContent < ActiveRecord::Migration
  def up

    unless column_exists? :contents, :custom_data
      add_column :contents, :custom_data, :text
    end

  end

  def down

    if column_exists? :contents, :custom_data
      drop_column :contents, :custom_data
    end

  end
end
