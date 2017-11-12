class CreateCollections < ActiveRecord::Migration
  def up
    unless table_exists?(:collections)
      create_table :collections do |t|
        t.string  :name
        t.text    :description
        t.string  :default_image_url
        t.integer :list_view_image_id
        t.string  :internal_identifier
        t.string  :external_identifier
        t.string  :external_id_source
        t.text    :custom_fields
        t.timestamps
      end
    end
  end

  def down
    if table_exists?(:collections)
      drop_table :collections
    end
  end
end
