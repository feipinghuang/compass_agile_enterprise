class AddRoleTypesAndProductTypesForBaseAndVariants
  
  def self.up
    # create a parent Product Type as the top node for base and variants
    parent_product_type = ProductType.create(
        description: 'Parent Product Type',
        internal_identifier: 'parent_product_type',
    )

    # create a base parent Product Type
    parent_base_product_type = ProductType.create(
        description: 'Parent_Base Product Type',
        internal_identifier: 'parent_base_product_type_parent',
    )
    parent_base_product_type.move_to_child_of(parent_product_type)

    # create a variant parent Product Type
    parent_variant_product_type = ProductType.create(
        description: 'Parent Variant Product Type',
        internal_identifier: 'parent_variant_product_type',
    )
    parent_variant_product_type.move_to_child_of(parent_product_type)

    # create a prod type reln for base to variant (no parent for now)
    prod_type_reln_type = ProdTypeRelnType.create(
        description: 'Product Type Base To Variant Relationship',
        internal_identifier: 'product_type_base_to_variant_relationship'
    )

    # add some role types just to keep it all together
    parent_product_role_type = RoleType.create(
        description: 'Product Role Type',
        internal_identifier: 'product_role_type'
    )
    base_product_role_type = RoleType.create(
        description: 'Base Product',
        internal_identifier: 'base_product'
    )
    base_product_role_type.move_to_child_of(parent_product_role_type)

    variant_product_role_type = RoleType.create(
        description: 'Variant Product',
        internal_identifier: 'variant_product'
    )
    variant_product_role_type.move_to_child_of(parent_product_role_type)

  end
  
  def self.down
    #remove data here
  end

end
