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

  def to_data_hash
    data = to_hash(only: [
                       :id,
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