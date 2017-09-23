# create_table :agreements do |t|
#   t.column  :description,       :string
#   t.column  :agreement_type_id, :integer
#   t.column  :agreement_status,  :string
#   t.column  :product_id,        :integer
#   t.column  :agreement_date,    :date
#   t.column  :from_date,         :date
#   t.column  :thru_date,         :date
#   t.column  :external_identifier, :string
#   t.column  :external_id_source,  :string
#
#   t.timestamps
# end
#
# add_index :agreements, :agreement_type_id
# add_index :agreements, :product_id

class Agreement < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_tenantable

  belongs_to :agreement_type
  has_many   :agreement_items, dependent: :destroy
  has_many   :agreement_party_roles, dependent: :destroy
  has_many   :parties, :through => :agreement_party_roles
  has_many   :agreement_records, dependent: :destroy

  alias :items :agreement_items

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @option filters [Integer | Party] :party Party to filter by
    # @option filters [String] :role_types Comma delimitted set of Role Types to filter by
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement)
      statement = statement.joins(agreement_party_roles: :role_type)

      if filters[:id]
        statement = statement.where(id: filters[:id])
      end

      # Filter by a party
      if filters[:party]
        statement = statement.where(agreement_party_roles: {party_id: filters[:party]})
      end

      # If roles are passed filter by the roles passed
      if filters[:role_types]
        # Get RoleTypes passed on what is passed
        if filters[:role_types].is_a? Array
          role_types = []
          filters[:role_types].each do |role_type|
            if role_type.is_a? RoleType
              role_types.push(role_type)
            else
              role_types.push(RoleType.iid(role_type))
            end
          end

        elsif filters[:role_types].is_a? RoleType
          role_types = [filters[:role_types]]

        else
          role_types = RoleType.where(internal_identifier: filters[:role_types].split(','))

        end

        statement = statement.where(agreement_party_roles: {role_type_id: role_types})
      end

      statement
    end
  end

  def agreement_relationships
    AgreementRelationship.where('agreement_id_from = ? OR agreement_id_to = ?',id,id)
  end

  def to_s
    description
  end

  def to_label
    to_s
  end

  def find_parties_by_role(role)
    self.parties.where("role_type_id = ?", role.id).all
  end

  def get_item_by_item_type_internal_identifier(item_type_internal_identifier)
    agreement_items.joins("join agreement_item_types on
                           agreement_item_types.id = 
                           agreement_items.agreement_item_type_id").where("agreement_item_types.internal_identifier = '#{item_type_internal_identifier}'").first
  end

  def respond_to?(m, include_private_methods = false)
    if super
      true
    else
      ((get_item_by_item_type_internal_identifier(m.to_s).nil? ? false : true))
    end
  end

  def method_missing(m, *args, &block)
    agreement_item = get_item_by_item_type_internal_identifier(m.to_s)
    (agreement_item.nil?) ? super : (return agreement_item.agreement_item_value)
  end

  def to_data_hash
    to_hash(only: [:id, :description, :agreement_status, :agreement_date, :from_date, :thru_date, :external_identifier, :external_id_source])
  end

end
