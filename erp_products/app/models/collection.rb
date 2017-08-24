class Collection < ActiveRecord::Base
  # create_table :collections do |t|
  #   t.string  :description
  #   t.string  :internal_identifier
  #   t.string  :external_identifier
  #   t.string  :external_id_source
  #   t.text    :custom_fields
  #
  #   t.timestamps

  attr_protected :created_at, :updated_at

  has_many :product_collections, dependent: :destroy
  has_many :product_types, through: :product_collections

end