class CreateProductCollections < ActiveRecord::Migration
  def change
    create_table :product_collections do |t|
      t.string      :description
      t.references  :collection
      t.references  :product_type

      t.timestamps
    end
  end
end
