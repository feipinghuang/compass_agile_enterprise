class AddCustomFieldsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :custom_fields, :text unless column_exists?(:notifications, :custom_fields)
  end
end
