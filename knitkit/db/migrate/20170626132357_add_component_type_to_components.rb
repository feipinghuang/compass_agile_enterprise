class AddComponentTypeToComponents < ActiveRecord::Migration
  def up
    unless column_exists? :contents, :component_type
      add_column :contents, :component_type, :string
      add_index :contents, :component_type, name: 'contents_component_type_idx'
    end
  end

  def down
    if column_exists? :contents, :component_type
      remove_column :contents, :component_type
    end
  end
end
