# unless table_exists?(:categories)
#   create_table :categories do |t|
#     t.string :description
#     t.string :external_identifier
#     t.datetime :from_date
#     t.datetime :to_date
#     t.string :internal_identifier
#
#     # polymorphic assns
#     t.integer :category_record_id
#     t.string :category_record_type
#
#     # nested set cols
#     t.integer :parent_id
#     t.integer :lft
#     t.integer :rgt
#
#     t.integer :tenant_id
#
#     t.timestamps
#   end
#   add_index :categories, [:category_record_id, :category_record_type], :name => "category_polymorphic"
#   add_index :categories, :internal_identifier, :name => 'categories_internal_identifier_idx'
#   add_index :categories, :parent_id, :name => 'categories_parent_id_idx'
#   add_index :categories, :lft, :name => 'categories_lft_idx'
#   add_index :categories, :rgt, :name => 'categories_rgt_idx'
#   add_index :categories, :tenant_id, name: 'categories_tenant_idx'
# end

class Category < ActiveRecord::Base
  
  is_tenantable
  acts_as_erp_type
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_file_assets

  attr_protected :created_at, :updated_at

  validates :internal_identifier, uniqueness: {allow_nil: false}

  belongs_to :category_record, :polymorphic => true
  has_many :category_classifications, :dependent => :destroy

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      unless statement
        statement = self
      end

      # filter by parent
      if filters[:parent]
        if filters[:parent].is_a? Fixnum || filters[:parent].is_integer?
          statement = statement.where(categories: {parent_id: filters[:parent]})
        else
          statement = statement.where(categories: {parent_id: Category.iid(filters[:parent])})
        end
      end

      # filter by query which will filter on description
      if filters[:query]
        statement = statement.where('description like ?', "%#{filters[:query].strip}%")
      end

      statement
    end

    # scope by dba organization
    #
    # @param dba_organization [Party] dba organization to scope by
    #
    # @return [ActiveRecord::Relation]
    def scope_by_dba_organization(dba_organization)
      scope_by_party(dba_organization, {role_types: 'dba_org'})
    end

    alias scope_by_dba scope_by_dba_organization

    # scope by party
    #
    # @param party [Integer | Party | Array] either a id of Party record, a Party record, an array of Party records
    # or an array of Party ids
    # @param options [Hash] options to apply to this scope
    # @option options [String | Array] :role_types BizTxnAcctPtyRtype internal identifiers to include in the scope,
    # comma separated or an Array
    #
    # @return [ActiveRecord::Relation]
    def scope_by_party(party, options={})
      statement = joins(:entity_party_roles)
                      .where(entity_party_roles: {party_id: party}).uniq

      if options[:role_types]
        role_types = options[:role_types]
        unless role_types.is_a? Array
          role_types = role_types.split(',')
        end

        statement = statement.joins(entity_party_roles: :role_type)
                        .where(role_types: {internal_identifier: role_types})
      end

      statement
    end

    def iid(internal_identifier)
      where("internal_identifier = ?", internal_identifier).first
    end
  end

  def to_data_hash
    data = to_hash(
        only: [
            :id,
            :description,
            :internal_identifier,
            :created_at,
            :updated_at
        ],
        leaf: leaf?
    )

    data['image_url'] = self.images.first.try(:fully_qualified_url)

    data
  end

end
