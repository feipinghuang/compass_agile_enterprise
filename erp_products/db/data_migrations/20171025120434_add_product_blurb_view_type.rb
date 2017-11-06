class AddProductBlurbViewType
  
  def self.up
    product_type_view_type = ViewType.find_by_internal_identifier('product_type_description')

    blurb = ViewType.create(description: 'Product Type Blurb',
                            internal_identifier: 'product_type_blurb')
    blurb.move_to_child_of(product_type_view_type)
  end
  
  def self.down
    #remove data here
  end

end
