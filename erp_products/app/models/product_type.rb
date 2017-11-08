# create_table :product_types do |t|
#   #these columns are required to support the behavior of the plugin 'better_nested_set'
#   #ALL products have the ability to act as packages in a nested set-type structure
#   #
#   #The package behavior is treated differently from other product_relationship behavior
#   #which is implemented using a standard relationship structure.
#   #
#   #This is to allow quick construction of highly nested product types.
#   t.column    :parent_id,              :integer
#   t.column    :lft,                    :integer
#   t.column    :rgt,                    :integer
#
#   #custom columns go here
#   t.column  :description,              :string
#   t.column  :product_type_record_id,   :integer
#   t.column  :product_type_record_type, :string
#   t.column  :external_identifier,      :string
#   t.column  :internal_identifier,      :string
#   t.column  :external_id_source,       :string
#   t.column  :default_image_url,        :string
#   t.column  :list_view_image_id,       :integer
#   t.column  :length,                   :decimal
#   t.column  :width,                    :decimal
#   t.column  :height,                   :decimal
#   t.column  :weight,                   :decimal
#   t.column  :cylindrical,              :boolean
#   t.column  :taxable                   :boolean
#   t.column  :available_on_web          :boolean
#
#   t.references :unit_of_measurement
#   t.references :revenue_gl_account
#   t.references :expense_gl_account
#
#   t.timestamps
# end
#
# add_index :product_types, :revenue_gl_account_id, name: 'product_types_rev_gl_acct_idx'
# add_index :product_types, :expense_gl_account_id, name: 'product_types_exp_gl_acct_idx'

class ProductType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  acts_as_taggable

  tracks_created_by_updated_by
  has_file_assets
  is_describable

  belongs_to :product_type_record, polymorphic: true
  belongs_to :unit_of_measurement

  belongs_to :revenue_gl_account, class_name: 'BizTxnAcctRoot', foreign_key: 'revenue_gl_account_id'
  belongs_to :expense_gl_account, class_name: 'BizTxnAcctRoot', foreign_key: 'expense_gl_account_id'

  has_one :product_instance
  has_many :product_type_pty_roles, dependent: :destroy

  has_many :product_type_discounts, dependent: :destroy
  has_many :discounts, through: :product_type_discounts

  has_many :product_collections, dependent: :destroy
  has_many :collections, through: :product_collections

  has_many :product_feature_applicabilities, dependent: :destroy, as: :feature_of_record

  has_one :category_classification, as: :classification, dependent: :destroy
  has_one :category, through: :category_classification

  has_many :product_option_applicabilities, dependent: :destroy, as: :optioned_record

  #
  # Added scoping of internal identifier uniqueness validation by tenant. This model
  # will eventually use is_tentantable
  #
  before_validation :set_tenant

  def set_tenant
    unless self.tenant_id
      self.tenant_id = self.try(:dba_organization).try(:id)
    end
  end

  validate :internal_identifier_uniqueness

  def internal_identifier_uniqueness
    if tenant_id.blank? && self.dba_organization.nil?
      if ProductType.where(ProductType.arel_table[:internal_identifier].eq(internal_identifier)
                           .and(ProductType.arel_table[:id].not_eq(self.id))).first

        errors.add(:internal_identifier, "must be unique")
      end
    else
      if ProductType.where(ProductType.arel_table[:internal_identifier].eq(internal_identifier)
                           .and(ProductType.arel_table[:tenant_id].eq(tenant_id))
                           .and(ProductType.arel_table[:id].not_eq(self.id))).first

        errors.add(:internal_identifier, "must be unique")
      end
    end
  end

  before_destroy :delete_related_records

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      unless statement
        statement = ProductType
      end

      if filters[:id]
        statement = statement.where(id: filters[:id])
      end

      if filters[:discount_ids]
        statement = statement.joins("inner join product_type_discounts on product_type_discounts.product_type_id = product_types.id")
        statement = statement.where('product_type_discounts.discount_id' => filters[:discount_ids])
      end

      if filters[:category_ids]
        statement = statement.joins("inner join category_classifications on category_classifications.classification_type = 'ProductType'
                         and category_classifications.classification_id = product_types.id")
        statement = statement.where('category_classifications.category_id' => filters[:category_ids])
      end

      if filters[:collection_ids]
        statement = statement.joins("inner join product_collections on product_collections.product_type_id = product_types.id")
        statement = statement.where('product_collections.collection_id' => filters[:collection_ids])
      end

      if filters[:party]
        if filters[:party].is_a? Hash
          statement = statement.scope_by_party(filters[:party][:id], {role_types: filters[:party][:role_types].split(',')})
        else
          statement = statement.scope_by_party(filters[:party])
        end
      end

      if filters and filters[:keyword]
        product_types_tbl = self.arel_table
        descriptive_assets_tbl = DescriptiveAsset.arel_table

        join_stmt = "LEFT OUTER JOIN descriptive_assets ON descriptive_assets.described_record_id = product_types.id AND descriptive_assets.described_record_type = 'ProductType' AND #{descriptive_assets_tbl[:description].matches('%' + filters[:keyword] + '%').to_sql}"

        statement = statement.joins(join_stmt).where(product_types_tbl[:description].matches('%' + filters[:keyword] + '%'))
      end

      if filters[:is_available_on_web]
        statement = statement.where(available_on_web: true)
      end

      if filters[:not_available_on_web]
        statement = statement.where(available_on_web: false)
      end

      if filters[:roots_only]
        statement = statement.where(is_base: true)
      end

      statement
    end

    #
    # scoping helpers
    #

    # scope by dba organization
    #
    # @param dba_organization [Party] dba organization to scope by
    #
    # @return [ActiveRecord::Relation]
    def scope_by_dba_organization(dba_organization)
      scope_by_party(dba_organization, {role_types: [RoleType.iid('dba_org')]})
    end

    # scope by party
    #
    # @param party [Integer | Party | Array] either a id of Party record, a Party record, an array of Party records
    # or an array of Party ids
    # @param options [Hash] options to apply to this scope
    # @option options [Array] :role_types role types to include in the scope
    #
    # @return [ActiveRecord::Relation]
    def scope_by_party(party, options={})
      statement = joins(:product_type_pty_roles).where("product_type_pty_roles.party_id" => party).uniq

      if options[:role_types]
        statement = statement.where("product_type_pty_roles.role_type_id" => RoleType.find_child_role_types(options[:role_types]))
      end

      statement
    end

    def find_product_by_features(choices)
      # given a product type, find the related product type with a specific feature value set
      # choices['product_type_id'] is current product type id
      # choices['n'] where 'n' is product feature type id and hash value product feature value id - one hash key for each feature
      #
      # first identify the parent of the family, product ype has to be within the family
      product_type = ProductType.find(choices['product_type_id'].to_i)
      if product_type.is_base
        candidate_product_type_ids = product_type.children.collect{ |child| child.id}
      else
        candidate_product_type_ids = ProductType.find(product_type.parent_id).children.collect{ |child| child.id}
      end
      # grab the product feature applicabilities for the candidate product types
      product_feature_applicabilities = ProductFeatureApplicability.where( "feature_of_record_type = ? and feature_of_record_id in (#{candidate_product_type_ids.join(',')})", "ProductType" )
      # grab the product_feature_ids that match the choices
      product_feature_ids = []
      choices.each do |key, value|
        unless key == 'product_type_id'
          product_feature_ids << ProductFeature.find_by_product_feature_type_id_and_product_feature_value_id(key.to_i, value.to_i).id
        end
      end
      product_feature_ids.sort!
      candidate_product_type_ids.each do |candidate_id|
        if product_feature_applicabilities.select{ |pfa| pfa.feature_of_record_id == candidate_id }.collect{ |pfa| pfa.product_feature_id}.sort == product_feature_ids
          return candidate_id
        end
      end
      nil
    end
  end


  # add party with passed role to this ProductType
  #
  # @param party [Party] party to add
  # @param role_type [RoleType] role type to use in the association
  # @return [ProductTypePtyRole] newly created relationship
  def add_party_with_role(party, role_type)
    ProductTypePtyRole.create(
        product_type: self,
        party: party,
        role_type: role_type
    )
  end

  def taxable?
    self.taxable
  end

  def prod_type_relns_to
    ProdTypeReln.where('prod_type_id_to = ?', id)
  end

  def prod_type_relns_from
    ProdTypeReln.where('prod_type_id_from = ?', id)
  end

  def to_label
    "#{description}"
  end

  def to_s
    "#{description}"
  end

  def self.count_by_status(product_type, prod_availability_status_type)
    ProductInstance.count("product_type_id = #{product_type.id} and prod_availability_status_type_id = #{prod_availability_status_type.id}")
  end

  def images_path
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    File.join(file_support.root, Rails.application.config.erp_tech_svcs.file_assets_location, 'products', 'images', "#{self.description.underscore}_#{self.id}")
  end

  def to_data_hash
    data = to_hash(only: [
                       :id,
                       :description,
                       :internal_identifier,
                       :sku,
                       :comment,
                       :created_at,
                       :updated_at
                   ],
                   offer_list_description: find_description_by_view_type('list_description').try(:description),
                   offer_short_description: find_description_by_view_type('short_description').try(:description),
                   offer_long_description: find_description_by_view_type('long_description').try(:description),
                   unit_of_measurement: try(:unit_of_measurement).try(:to_data_hash),
                   price: try(:get_current_simple_plan).try(:money_amount),
                   cost: custom_fields['cost'],
                   revenue_gl_account: try(:revenue_gl_account).try(:to_data_hash),
                   expense_gl_account: try(:expense_gl_account).try(:to_data_hash),
                   img_url: images.first.try(:fully_qualified_url),
                   vendor: find_party_by_role(RoleType.iid('vendor')).try(:description),
                   images: [])

    if self.images.empty?
      data[:images] << "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{Rails.configuration.assets.prefix}/place_holder.jpeg"
    else
      self.images.each do |image|
        data[:images] << image.fully_qualified_url
      end
    end

    data[:options] = product_option_applicabilities.collect{|item| item.to_data_hash({include_options: true})}

    data
  end

  def to_target_hash()
    # hash used by both discounts and collections custom views
    images = []
    if self.images.empty?
      images << "#{ErpTechSvcs::Config.file_protocol}://#{ErpTechSvcs::Config.installation_domain}/#{Rails.configuration.assets.prefix}/place_holder.jpeg"
    else
      self.images.each do |image|
        images << image.fully_qualified_url
      end
    end

    {
       id: id,
       description: description,
       children: [], # no roots passed
       discount_price: 0.0,
       is_base: is_base,
       is_leaf: leaf?,
       leaf: leaf?,
       price: try(:get_current_simple_plan).try(:money_amount),
       images: images.first,
       sku: is_base ? 'base' : sku,
       created_at: created_at,
       updated_at: updated_at,
       discount_info: discount_info,
       category: category.description,
       number_in_stock: number_in_stock,
       number_available: number_available,
       number_sold: number_sold
    }

  end

  def discount_info
    discount_details = []

    product_type_discounts.sort_by{|ptd| ptd.id}.each do |product_type_discount|
      discount = Discount.find(product_type_discount.discount_id)
      discount_details << {discount_name: discount.description, discount_price: discount_price(discount.id).nil? ? 0.0 : discount_price(discount.id)}
    end


    discount_details
  end

  def to_display_hash
    {
        id: id,
        description: description,
        offer_list_description: find_descriptions_by_view_type('list_description').first.try(:description),
        offer_short_description: find_descriptions_by_view_type('short_description').first.try(:description),
        offer_long_description: find_descriptions_by_view_type('long_description').first.try(:description),
        offer_base_price: get_current_simple_amount_with_currency,
        images: images.pluck(:id)
    }
  end

  def to_mobile_hash
    to_data_hash
  end

  # Get dba_organzation info eventually going to be tenant
  def dba_organization
    find_party_by_role(RoleType.iid('dba_org'))
  end
  alias :tenant :dba_organization

  def parent_dba_organizations(dba_orgs=[])
    ProductTypePtyRole.
        where('product_type_id = ?', id).
        where('role_type_id' => RoleType.iid('dba_org').id).each do |prod_party_reln|

      dba_orgs.push(prod_party_reln.party)
      prod_party_reln.party.parent_dba_organizations(dba_orgs)
    end

    dba_orgs.uniq
  end

  def add_party_with_role(party, role_type)
    if role_type.is_a?(String)
      role_type = RoleType.iid(role_type)
    end

    # if this is a dba_org role then set the tenant_id
    if role_type.internal_identifier == 'dba_org'
      self.tenant_id = party.id
      self.save
    end

    ProductTypePtyRole.create(party: party, role_type: role_type, product_type: self)
  end

  def find_party_by_role(role_types)
    unless role_types.is_a? Array
      role_types = [role_types]
    end

    role_types = RoleType.find_child_role_types(role_types)

    product_type_pty_roles.where(role_type_id: role_types).first.try(:party)
  end

  def has_dimensions?
    (cylindrical && length && width && weight) or (length && width && height && weight)
  end

  def generate_variants

    dba_org_role_type = RoleType.iid('dba_org')


    product_features = []
    product_feature_applicabilities.each do |product_feature_applicability|
      product_feature = product_feature_applicability.product_feature
      feature_type_and_value = {}
      feature_type_and_value[:type_id] = product_feature.product_feature_type_id
      feature_type_and_value[:value_id]  = product_feature.product_feature_value_id
      product_features << feature_type_and_value
    end

    # get an array of unique type ids
    unique_type_ids = product_features.map {|product_feature| product_feature[:type_id]}.uniq


    # get the value ids for each type
    value_sets = []
    unique_type_ids.each do |type_id|
      value_set = []
      product_features.each do |product_feature|
        if product_feature[:type_id] == type_id
          value_set << product_feature[:value_id]
        end
      end
      value_sets << value_set
    end

    # get the unique permutations of each value id set
    # 'product' is ruby array product, not product as in product_type
    permutations = value_sets.inject(&:product).map(&:flatten)

    # get the product features for each unique combination of values
    product_feature_sets = []
    permutations.each do |permutation|
      product_feature_set = []
      permutation.each do |value_id|
        product_feature = ProductFeature.find_by_product_feature_value_id(value_id)
        product_feature_set << product_feature
      end
      product_feature_sets << product_feature_set
    end

    parent_variant_product_type = self
    prod_type_reln_type = ProdTypeRelnType.find_by_internal_identifier('product_type_base_to_variant_relationship')
    base_product_role_type = RoleType.iid('base_product')
    variant_product_role_type = RoleType.iid('variant_product')

    # for each feature set, create a variant product type and relate it to the base product
    product_feature_sets.each do |variant_features_set|

      sku = "v" + rand(1234567).to_s

      # these fields distinguish between 'service' and 'item' products



      variant_product_type = ProductType.create(
          internal_identifier: "#{self.internal_identifier}_variant_#{sku}",
          revenue_gl_account_id: self.revenue_gl_account_id,
          expense_gl_account_id: self.expense_gl_account_id,
          sku: sku,
          width: self.width.present? ? self.width : nil,
          height: self.height.present? ? self.height : nil,
          length: self.length.present? ? self.length : nil,
          weight: self.weight.present? ? self.weight : nil,
          available_on_web: self.available_on_web.present? ? self.available_on_web : nil,
          unit_of_measurement_id: self.unit_of_measurement_id.present? ? variant_uom_id = self.width : nil,
          is_base: false
      )

      # experimental code
      parent_product_image = self.images.first
      file_asset_holder = FileAssetHolder.new
      file_asset_holder.file_asset_id = parent_product_image.id
      file_asset_holder.file_asset_holder_id = variant_product_type.id
      file_asset_holder.file_asset_holder_type = 'ProductType'
      file_asset_holder.created_at = DateTime.now
      file_asset_holder.updated_at = DateTime.now
      file_asset_holder.save

      variant_product_type.move_to_child_of(parent_variant_product_type)

      features_list = ""

      variant_features_set.each do |variant_feature|
        ProductFeatureApplicability.create(
            is_mandatory: true,
            feature_of_record_type: 'ProductType',
            feature_of_record_id: variant_product_type.id,
            product_feature_id: variant_feature.id
        )
        feature_value = ProductFeatureValue.find(variant_feature.product_feature_value_id)
        features_list.concat(feature_value.description + '-')
      end

      variant_product_type.description = self.description + ' (' + features_list.slice(0,(features_list.length - 1)) +')'
      variant_product_type.save

      # put the variant in the same category as the base (parent)
      parent_category = self.category
      CategoryClassification.create(category: parent_category,  classification: variant_product_type)

      # if the base (parent) has a vendor specified via product type party roles
      # create a vendor party role for the variant
      product_type_pty_roles.each do |product_type_party_role|
        if product_type_party_role.is_vendor_role?
          ProductTypePtyRole.create(
             party_id: product_type_party_role.party_id,
             role_type_id: product_type_party_role.role_type_id,
             product_type_id: variant_product_type.id
          )
        end
      end

      # grab that cost from the custom field on self
      cost = ActiveSupport::JSON.decode(self.custom_fields['cost'])
      variant_custom_fields = {}
      variant_custom_fields['cost'] = cost
      variant_product_type.custom_fields = variant_custom_fields

      # add default pricing that matches the base product
      # add pricing plan
      pricing_plan = PricingPlan.new
      pricing_plan.description = "#{variant_product_type.description} Pricing Plan"
      pricing_plan.internal_identifier = "#{variant_product_type.internal_identifier}_pricing_plan"
      pricing_plan.is_simple_amount = true
      pricing_plan.money_amount = self.get_current_simple_plan.money_amount
      pricing_plan.save

      variant_product_type.pricing_plans << pricing_plan
      variant_product_type.save

      # Auto Generate Inventory Entry for Generated Variants
      inventory_entry = InventoryEntry.new
      inventory_entry.description = variant_product_type.description
      inventory_entry.sku = variant_product_type.sku
      inventory_entry.unit_of_measurement_id = variant_product_type.unit_of_measurement_id
      inventory_entry.number_in_stock = 0
      inventory_entry.number_available = 0
      inventory_entry.product_type_id = variant_product_type.id
      inventory_entry.tenant_id = self.product_type_pty_roles.first.party_id
      inventory_entry_custom_fields = {}
      inventory_entry_custom_fields['when_sold_out'] = 'Stop Selling'
      inventory_entry.custom_fields = inventory_entry_custom_fields
      inventory_entry.save

      # bind the variant product back to the base product
      ProdTypeReln.create(
          prod_type_reln_type_id: prod_type_reln_type,
          description: 'Base Product to Variant Product',
          prod_type_id_to: self.id,
          prod_type_id_from: variant_product_type.id,
          role_type_id_to: base_product_role_type.id,
          role_type_id_from: variant_product_role_type.id
      )

      # create a ProductTypePtyRole for each variant
      # for the dba orgqnization
      ProductTypePtyRole.create(
          # use the party id of the base product
          party_id: self.dba_organization.id,
          role_type_id: dba_org_role_type.id,
          product_type_id: variant_product_type.id
      )

    end
  end

  def product_feature_types_with_values
    unless product_feature_applicabilities.empty?
      product_features = []
      ProductFeature.where("id in (#{product_feature_applicabilities.collect{ |pfa| pfa.product_feature_id}.join(',')})").each do |product_feature|
        product_features << product_feature
      end
      feature_type_ids = []
      product_features.each do |product_feature|
        tmp = [product_feature.product_feature_type_id, product_feature.product_feature_value_id]
        feature_type_ids << product_feature.product_feature_type_id
      end
      feature_type_ids.uniq!
      result = []
      feature_type_ids.each do |feature_type_id|
        result_hash = {}
        result_hash[:feature_type] = ProductFeatureType.find(feature_type_id).description
        result_hash[:feature_type_id] = feature_type_id
        features_for_type_ids= product_features.select{ |pf| pf.product_feature_type_id == feature_type_id}
        features = []
        features << ['Select', 0]
        features_for_type_ids.each do |feature_for_type_id|
          product_feature_value = ProductFeatureValue.find(feature_for_type_id.product_feature_value_id)
          feature_values = [product_feature_value.description,product_feature_value.id]
          features << feature_values
        end
        result_hash[:feature_values] = features
        result << result_hash
      end
    else
      result = []
    end
    result
  end

  def featureless?
    is_base && children.length == 0
  end

  def in_discount_as_base?(discount_id)
    is_base && discounts.collect{|d| d.id }.include?(discount_id)
  end

  def in_collection_as_base?(collection_id)
    is_base && collections.collect{|c| c.id }.include?(collection_id)
  end

  def product_feature_values
    product_values = []
    product_feature_applicabilities.each do |product_feature_applicabiity|
      product_feature = ProductFeature.find(product_feature_applicabiity.product_feature_id)
      product_values << ProductFeatureValue.find(product_feature.product_feature_value_id).description
    end
    product_values.join(",")
  end

  def has_features?
    product_feature_applicabilities.count > 0
  end

  def has_variants?
    children.length > 0
  end

  # helpers to grab inventory counts
  def number_in_stock
    number_in_stock = 0.0
    if is_base
      children.each do |child_product_type|
        child_product_type.inventory_entries.each do |inventory_entry|
          number_in_stock += inventory_entry.number_in_stock
        end
      end
    else
      inventory_entries.each do |inventory_entry|
        number_in_stock += inventory_entry.number_in_stock
      end
    end
    number_in_stock
  end

  def number_available
    number_available = 0.0
    if is_base
      children.each do |child_product_type|
        child_product_type.inventory_entries.each do |inventory_entry|
          number_available += inventory_entry.number_available
        end
      end
    else
      inventory_entries.each do |inventory_entry|
        number_available += inventory_entry.number_available
      end
    end
    number_available
  end

  def number_sold
    number_sold = 0.0
    if is_base
      children.each do |child_product_type|
        child_product_type.inventory_entries.each do |inventory_entry|
          number_sold += inventory_entry.number_sold
        end
      end
    else
      inventory_entries.each do |inventory_entry|
        number_sold += inventory_entry.number_sold
      end
    end
    number_sold
  end

  def when_sold_out
    if is_base
      '---'
    else
      inventory_entries.first.custom_fields['when_sold_out']
    end
  end

  def discount_price(discount_id)
    # if there is currently a discount in place for this product type
    # return the discount price, else return nil
    now = DateTime.now
    price = nil
    product_offer = ProductOffer.find_by_discount_id_and_product_type_id(discount_id,self.id)
    unless product_offer.nil?
      discount = product_offer.discount
      if discount_valid?(discount)
        price = product_offer.product_offer_record.get_current_simple_plan.money_amount
      else
        price = self.get_current_simple_plan.money_amount
      end
    end
    price
  end

  def discount_valid?(discount)
    # if date matter check dates
    # if active
    if discount.active
      if discount.date_constrained
        now = DateTime.now
        if (!discount.valid_from.nil? && discount.valid_from <= now) && (!discount.valid_thru.nil? &&  discount.valid_thru >= now )
          return true
        else
          return false
        end
      else
        return true
      end
    else
      return false
    end
  end

  def at_least_one_child_in_discount?(discount_id)
    children.each do |child_product_type|
      product_types_discounts = ProductTypeDiscount.where('discount_id = ? and product_type_id = ?', discount_id, self.id)
      if product_types_discounts.length > 0
        return true
      end
    end
    return false
  end

  def at_least_one_child_not_in_discount?(discount_id)

    child_product_type_ids = children.collect{ |child| child.id}

    # if no children, return false. never show a product type without children in discount
    # Search Results because base product types can't really be sold
    if child_product_type_ids.empty?
      return false
    end

    number_of_children_in_discount = ProductTypeDiscount.where("discount_id = ? and product_type_id in (#{child_product_type_ids.join(',')})", discount_id).length

    if( child_product_type_ids.length > number_of_children_in_discount )
      return true
    else
      return false
    end

  end

  def at_least_one_child_in_collection?(collection_id)
    children.each do |child_product_type|
      product_collections = ProductCollection.where('collection_id = ? and product_type_id = ?', collection_id, child_product_type.id)
      if product_collections.length > 0
        return true
      end
    end
    return false
  end

  def at_least_one_child_not_in_collection?(collection_id)

    child_product_type_ids = children.collect{ |child| child.id}

    # if no children, return false. never show a product type without children in discount
    # Search Results because base product types can't really be sold
    if child_product_type_ids.empty?
      return false
    end

    number_of_children_in_collection = ProductCollection.where("collection_id = ? and product_type_id in (#{child_product_type_ids.join(',')})", collection_id).length

    if( child_product_type_ids.length > number_of_children_in_collection )
      return true
    else
      return false
    end

  end

  private

  def delete_related_records
    # clean up any product offers realted to this product type
    product_offers = ProductOffer.where('product_type_id = ?', self.id)
    product_offers.each do |product_offer|
      product_offer.delete
    end
    # clean up any variants if this is a base product type
    # semi-experimental code: this assumes children were
    # generated and should not outlive the parent base.
    if is_base
      children.each do |child|
        child.delete
      end
    end
  end



end


module Arel
  class SelectManager
    def polymorphic_join(hash={polytable: nil, table: nil, model: nil, polymodel: nil, record_type_name: nil, record_id_name: nil, table_model: nil})
      # Left Outer Join with 2 possible hash argument sets:
      #   1) model (AR model), polymodel (AR model), record_type_name (symbol), record_id_name (symbol)
      #   2) polytable (arel_table), table (arel_table), record_type_name (symbol), record_id_name (symbol), table_model (string)

      if hash[:model] && hash[:polymodel]
        self.join(hash[:polymodel].arel_table, Arel::Nodes::OuterJoin).on(hash[:polymodel].arel_table[hash[:record_id_name]].eq(hash[:model].arel_table[:id]).and(hash[:polymodel].arel_table[hash[:record_type_name]].eq(hash[:model].to_s)))
      elsif hash[:polytable] && hash[:record_type_name]
        self.join(hash[:polytable], Arel::Nodes::OuterJoin).on(hash[:polytable][hash[:record_id_name]].eq(hash[:table][:id]).and(hash[:polytable][hash[:record_type_name]].eq(hash[:table_model])))
      else
        raise 'Invalid Args'
      end
    end
  end
end
