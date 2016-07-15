class AddIsInternalCategory < ActiveRecord::Migration
  def up
    unless column_exists? :categories, :is_internal
      add_column :categories, :is_internal, :boolean, default: false
      add_index :categories, :is_internal, name: 'categories_is_internal_idx'
    end
  end

  def down
    if column_exist? :categories, :is_internal
      remove_column :categories, :is_internal
    end
  end
end
