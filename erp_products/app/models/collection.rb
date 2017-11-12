class Collection < ActiveRecord::Base
  # create_table :collections do |t|
  #   t.string  :name
  #   t.text    :description
  #   t.string  :default_image_url
  #   t.integer :list_view_image_id
  #   t.string  :internal_identifier
  #   t.string  :external_identifier
  #   t.string  :external_id_source
  #   t.text    :custom_fields
  #   t.integer   :tenant_id
  #   t.timestamps


  has_file_assets
  is_tenantable

  attr_protected :created_at, :updated_at

  has_many :product_collections, dependent: :destroy
  has_many :product_types, through: :product_collections

  validates :description, :uniqueness => true, :allow_nil => false

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      unless statement
        # :: to prevent clash with act as taggable Collection classs
        statement = ::Collection
      end

      if filters[:id]
        statement = statement.where(id: filters[:id])
      end

      if filters and filters[:keyword]
        collection_tbl = self.arel_table
        statement = statement.where(collection_tbl[:description].matches('%' + filters[:keyword] + '%'))
      end

      statement
    end
  end

  def add_products(product_type_ids,product_type_tag)

    product_type_ids.each do |product_type_id|
      # be defensive: only add if not exist
      product_collection = ProductCollection.find_by_collection_id_and_product_type_id(self.id, product_type_id)
      if product_collection.nil?
        ProductCollection.create(
             collection_id: self.id,
             product_type_id: product_type_id
        )
      end

      # tag these products if there's a tag
      unless product_type_tag.blank?
        product_type = ProductType.find(product_type_id)
        product_type.tag_list.add(product_type_tag.to_s, parse: true)
        product_type.save
      end
    end

  end

  def remove_products(product_type_ids,product_type_tag)

    product_type_ids_to_remove = []

    if product_type_ids.length == 0
      product_type_ids_to_remove = product_collections.collect{|product_collection| product_collection.product_type_id}
    else
      product_type_ids.each do |product_type_id|
        product_type = ProductType.find(product_type_id)
        if product_type.is_base
          product_type_ids_to_remove = product_type.children.collect{|child| child.id}
          product_type_ids_to_remove << product_type.id
        else
          product_type_ids_to_remove << product_type_id
        end
      end
    end

    product_type_ids_to_remove.each do |product_type_id|
      # be defensive: only delete if exists
      product_collection = ProductCollection.find_by_collection_id_and_product_type_id(self.id, product_type_id)
      unless product_collection.nil?
        product_collection.delete
      end

      unless product_type_tag.blank?
        product_type = ProductType.find(product_type_id)
        product_type.tag_list.remove(product_type_tag)
        product_type.save
      end
    end


  end

  def to_data_hash
    data = to_hash(only: [
                       :id,
                       :name,
                       :default_image_url,
                       :description,
                       :internal_identifier,
                       :created_at,
                       :updated_at
                   ])

    # Add product type ids
    data[:product_type_ids] = product_collections.collect { |c| c.product_type_id}

    data
  end

  def to_mobile_hash
    to_data_hash
  end

end