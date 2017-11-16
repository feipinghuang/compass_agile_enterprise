class CreateProductCollections < ActiveRecord::Migration
  def up
    unless table_exists?(:product_collections)
      create_table :product_collections do |t|
        t.string      :description
        t.references  :collection
        t.references  :product_type

        t.timestamps
      end
    end
  end

  def down
    if table_exists? :product_collections
      drop_table :product_collections
    end
  end
end
