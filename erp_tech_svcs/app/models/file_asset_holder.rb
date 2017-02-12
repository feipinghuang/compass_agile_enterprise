# create_table :file_asset_holders do |t|
#   t.references :file_asset
#   t.references :file_asset_holder, :polymorphic => true
#   t.text :scoped_by
#
#   t.timestamps
# end
#
# add_index :file_asset_holders, :file_asset_id, :name => 'file_asset_holder_file_id_idx'
# add_index :file_asset_holders, [:file_asset_holder_id, :file_asset_holder_type], :name => 'file_asset_holder_idx'

class FileAssetHolder < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :file_asset, class_name: 'FileAsset', foreign_key: 'file_asset_id'
  belongs_to :file_asset_holder, :polymorphic => true

  # setup scoping
  add_scoped_by :scoped_by
end
