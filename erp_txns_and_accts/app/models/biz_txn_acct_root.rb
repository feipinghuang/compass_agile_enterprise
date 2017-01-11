# create_table :biz_txn_acct_roots do |t|
#   t.string   :description
#   t.string   :internal_identifier
#   t.integer  :status
#   t.integer  :biz_txn_acct_id
#   t.string   :biz_txn_acct_type
#   t.string   :external_identifier
#   t.string   :external_id_source
#   t.string   :type
#
#   t.integer  :parent_id
#   t.integer  :lft
#   t.integer  :rgt
#
#   t.references :biz_txn_acct_type
#   t.timestamps
# end
#
# add_index :biz_txn_acct_roots, [:biz_txn_acct_id, :biz_txn_acct_type], :name => "btai_2"
# add_index :biz_txn_acct_roots, :biz_txn_acct_type_id, :name => "btai_3"
# add_index :biz_txn_acct_roots, :parent_id
# add_index :biz_txn_acct_roots, :lft
# add_index :biz_txn_acct_roots, :rgt

class BizTxnAcctRoot < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_tracked_status
  tracks_created_by_updated_by

  belongs_to :biz_txn_acct, :polymorphic => true
  belongs_to :biz_txn_acct_type
  has_many :biz_txn_events, :dependent => :destroy
  has_many :biz_txn_acct_party_roles, :dependent => :destroy
  has_many :to_biz_txn_acct_relns, class_name: 'BizTxnAcctRelationship', foreign_key: 'biz_txn_acct_root_id_to'
  has_many :from_biz_txn_acct_relns, class_name: 'BizTxnAcctRelationship', foreign_key: 'biz_txn_acct_root_id_from'

  alias :account :biz_txn_acct
  alias :txn_events :biz_txn_events
  alias :txns :biz_txn_events
  alias :txn_account_type :biz_txn_acct_type

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
        if filters[:parent].is_integer?
          statement = statement.where(biz_txn_acct_roots: {parent_id: filters[:parent]})
        else
          statement = statement.where(biz_txn_acct_roots: {parent_id: BizTxnAcctRoot.iid(filters[:parent])})
        end
      end

      # filter by query which will filter on description
      if filters[:query]
        statement = statement.where('description like ?', "%#{filters[:query].strip}%")
      end

      # filter by BizTxnAcctType
      unless filters[:biz_txn_acct_type_iids].blank?
        statement = statement.joins(:biz_txn_acct_type).where(biz_txn_acct_types: {internal_identifier: filters[:biz_txn_acct_type_iids]})
      end

      # filter by Status
      unless filters[:status].blank?
        statement = statement.with_current_status(filters[:status].split(','))
      end

      unless filters[:parties].blank?
        data = JSON.parse(filters[:parties])

        statement = statement.scope_by_party(data['party_ids'].split(','), {role_types: data['role_types']})
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
      statement = joins(:biz_txn_acct_party_roles)
      .where(biz_txn_acct_party_roles: {party_id: party}).uniq

      if options[:role_types]
        role_types = options[:role_types]
        unless role_types.is_a? Array
          role_types = role_types.split(',')
        end

        statement = statement.joins(biz_txn_acct_party_roles: :biz_txn_acct_pty_rtype)
        .where(biz_txn_acct_pty_rtypes: {internal_identifier: role_types})
      end

      statement
    end

    # Look up account by internal identifier
    #
    # @param internal_identifier [String] Internal Identifier to look up by
    def iid(internal_identifier)
      where('internal_identifier = ?', internal_identifier).first
    end
  end

  def dba_organization
    _dba_org = find_party_by_role('dba_org')

    unless _dba_org
      _dba_org = find_party_by_role('subscription_owner').try(:dba_organization)
    end

    unless _dba_org
      _dba_org = find_party_by_role('account_owner').try(:dba_organization)
    end

    unless _dba_org
      _dba_org = find_party_by_role('owner').try(:dba_organization)
    end

    _dba_org
  end
  alias :dba_org :dba_organization
  alias :tenant :dba_organization
  def tenant_id
    tenant.id
  end

  def to_label
    "#{description}"
  end

  def to_s
    "#{description}"
  end

  def add_party_with_role(party, biz_txn_acct_pty_rtype, description=nil)
    biz_txn_acct_pty_rtype = BizTxnAcctPtyRtype.find_or_create(biz_txn_acct_pty_rtype, biz_txn_acct_pty_rtype.humanize) if biz_txn_acct_pty_rtype.is_a? String
    raise "BizTxnAcctPtyRtype #{biz_txn_acct_pty_rtype.to_s} does not exist" if biz_txn_acct_pty_rtype.nil?

    # get description from biz_txn_acct_pty_rtype if not passed
    description = biz_txn_acct_pty_rtype.description unless description

    self.biz_txn_acct_party_roles << BizTxnAcctPartyRole.create(:party => party, :description => description, :biz_txn_acct_pty_rtype => biz_txn_acct_pty_rtype)
    self.save
  end

  def find_parties_by_role(biz_txn_acct_pty_rtype)
    biz_txn_acct_pty_rtype = BizTxnAcctPtyRtype.find_or_create(biz_txn_acct_pty_rtype, biz_txn_acct_pty_rtype.humanize) if biz_txn_acct_pty_rtype.is_a? String
    raise "BizTxnAcctPtyRtype #{biz_txn_acct_pty_rtype.to_s} does not exist" if biz_txn_acct_pty_rtype.nil?

    Party.joins('inner join biz_txn_acct_party_roles on biz_txn_acct_party_roles.party_id = parties.id')
    .where('biz_txn_acct_pty_rtype_id = ?', biz_txn_acct_pty_rtype.id)
    .where('biz_txn_acct_root_id = ?', self.id)
  end

  def find_party_by_role(biz_txn_acct_pty_rtype)
    find_parties_by_role(biz_txn_acct_pty_rtype).first
  end

  def to_data_hash
    to_hash(only: [:id, :description, :internal_identifier])
  end

end
