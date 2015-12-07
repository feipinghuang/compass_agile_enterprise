#### Table Definition ###########################
#  create_table :biz_txn_events do |t|
#  	t.column  :description,  			    :string
#  	t.column	:biz_txn_acct_root_id, 	:integer
#  	t.column	:biz_txn_type_id,       :integer
#  	t.column 	:entered_date,          :datetime
#  	t.column 	:post_date,             :datetime
#  	t.column  :biz_txn_record_id,    	:integer
#  	t.column  :biz_txn_record_type,  	:string
#  	t.column 	:external_identifier, 	:string
#  	t.column 	:external_id_source, 	  :string
#  	t.timestamps
#  end
#
#  add_index :biz_txn_events, :biz_txn_acct_root_id
#  add_index :biz_txn_events, :biz_txn_type_id
#  add_index :biz_txn_events, [:biz_txn_record_id, :biz_txn_record_type], :name => "btai_1"
#################################################

class BizTxnEvent < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :biz_txn_acct_root
  belongs_to :biz_txn_record, :polymorphic => true
  has_many :biz_txn_party_roles, :dependent => :destroy
  has_many :biz_txn_event_descs, :dependent => :destroy
  has_many :base_txn_contexts, :dependent => :destroy
  has_many :biz_txn_agreement_roles
  has_many :agreements, :through => :biz_txn_agreement_roles

  before_destroy :destroy_biz_txn_relationships

  #wrapper for...
  #belongs_to :biz_txn_type
  belongs_to_erp_type :biz_txn_type

  #syntactic sugar
  alias :txn_type :biz_txn_type
  alias :txn_type= :biz_txn_type=
  alias :txn :biz_txn_record
  alias :txn= :biz_txn_record=
  alias :account :biz_txn_acct_root
  alias :account= :biz_txn_acct_root=
  alias :descriptions :biz_txn_event_descs

  has_tracked_status

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement)
      biz_txn_event_tbl = BizTxnEvent.arel_table

      # filter by query which will filter on description
      if filters[:query]
        statement = statement.where('description like ?', "%#{filters[:query].strip}%")
      end

      # filter by WorkEffortType
      unless filters[:biz_txn_type_iids].blank?
        statement = statement.where(biz_txn_type_id: BizTxnType.where(internal_identifier: filters[:biz_txn_type_iids]))
      end

      # filter by Status
      unless filters[:status].blank?
        statement = statement.with_current_status(filters[:status].split(','))
      end

      # filter by start_at
      unless filters[:start_date].blank?
        statement = statement.where(biz_txn_event_tbl[:entered_date].gteq(Time.parse(filters[:start_date])))
      end

      # filter by end_at
      unless filters[:end_date].blank?
        statement = statement.where(biz_txn_event_tbl[:entered_date].lteq(Time.parse(filters[:end_date])))
      end

      unless filters[:parties].blank?
        data = JSON.parse(filters[:parties])

        statement = statement.scope_by_party(data['party_ids'].split(','), {role_types: data['role_types']})
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
      dba_org_role_type = BizTxnPartyRoleType.find_or_create('dba_org', 'DBA Organization')

      joins("inner join biz_txn_party_roles on biz_txn_party_roles.biz_txn_event_id = biz_txn_events.id")
          .where('biz_txn_party_roles.party_id' => dba_organization)
          .where('biz_txn_party_roles.biz_txn_party_role_type_id' => dba_org_role_type)
    end

    alias scope_by_dba scope_by_dba_organization

    # scope by party
    #
    # @param party [Integer | Party | Array] either a id of Party record, a Party record, an array of Party records
    # or an array of Party ids
    # @param options [Hash] options to apply to this scope
    # @option options [String | Array] :role_types BizTxnPartyRoleType internal identifiers to include in the scope,
    # comma separated or an Array
    #
    # @return [ActiveRecord::Relation]
    def scope_by_party(party, options={})
      statement = joins("inner join biz_txn_party_roles on biz_txn_party_roles.biz_txn_event_id = biz_txn_events.id")
                      .where("biz_txn_party_roles.party_id" => party).uniq

      if options[:role_types]
        role_types = options[:role_types]
        unless role_types.is_a? Array
          role_types = role_types.split(',')
        end

        statement = statement.joins("inner join biz_txn_party_role_types
                                     on biz_txn_party_role_types.id = biz_txn_party_roles.biz_txn_party_role_type_id")
                        .where(biz_txn_party_role_types: {internal_identifier: role_types})
      end

      statement
    end
  end

  # Get the dba_organization related to this BizTxnEvent
  #
  # @return [Party] returns a Party if the dba organization was found
  def dba_organization
    dba_org_role_type = BizTxnPartyRoleType.find_or_create('dba_org', 'DBA Organization')

    biz_txn_party_role = biz_txn_party_roles.where('biz_txn_party_roles.biz_txn_party_role_type_id' => dba_org_role_type).first

    if biz_txn_party_role
      biz_txn_party_role.party
    end
  end

  alias dba_org dba_organization

  def destroy_biz_txn_relationships
    BizTxnRelationship.where("txn_event_id_from = ? or txn_event_id_to = ?", self.id, self.id).destroy_all
  end

  # helps when looping through transactions comparing types
  #
  def txn_type_iid
    biz_txn_type.internal_identifier if biz_txn_type
  end

  # get biz_txn_acct_root
  #
  # @return [BizTxnAcctRoot]
  def account_root
    biz_txn_acct_root
  end

  # get the amount of this txn if it responds to amount
  #
  # @return [BigDecimal | nil]
  def amount
    if biz_txn_record.respond_to? :amount
      biz_txn_record.amount
    else
      nil
    end
  end

  # get the amount of this txn as a string if it responds to amount_string
  #
  # @return [String | nil]
  def amount_string
    if biz_txn_record.respond_to? :amount_string
      biz_txn_record.amount_string
    else
      "n/a"
    end
  end

  # gets the first party related to this BizTxnEvent with the given BizTxnPartyRoleType
  #
  # @param role_type [BizTxnPartyRoleType | String] BizTxnPartyRoleType or internal identifier of BizTxnPartyRoleType
  # @return [Party | nil]
  def find_party_by_role_type(role_type)
    role_type = role_type.is_a?(String) ? BizTxnPartyRoleType.iid(role_type) : role_type

    biz_txn_party_role = biz_txn_party_roles.where(:biz_txn_party_role_type_id => role_type.id).first

    if biz_txn_party_role
      biz_txn_party_role.party
    end
  end

  # returns description of this BizTxnEvent
  #
  # @return [String]
  def to_label
    "#{description}"
  end

  # returns description of this BizTxnEvent
  #
  # @return [String]
  def to_s
    "#{description}"
  end

  # converts this record a hash data representation
  #
  # @return [Hash]
  def to_data_hash
    data = to_hash(only: [:id,
                          :description,
                          :entered_date,
                          :post_date,
                          :external_identifier,
                          :external_id_source,
                          :created_at,
                          :updated_at])

    data[:status] = self.try(:current_status_application).try(:to_data_hash)

    data
  end

  # template method to create dependent BizTxnEvents
  #
  def create_dependent_txns
    #Template Method
  end

end
