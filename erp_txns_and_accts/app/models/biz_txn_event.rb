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

  def destroy_biz_txn_relationships
    BizTxnRelationship.where("txn_event_id_from = ? or txn_event_id_to = ?", self.id, self.id).destroy_all
  end

  #helps when looping through transactions comparing types
  def txn_type_iid
    biz_txn_type.internal_identifier if biz_txn_type
  end

  def account_root
    biz_txn_acct_root
  end

  def amount
    if biz_txn_record.respond_to? :amount
      biz_txn_record.amount
    else
      nil
    end
  end

  def amount_string
    if biz_txn_record.respond_to? :amount_string
      biz_txn_record.amount_string
    else
      "n/a"
    end
  end

  def find_party_by_role_type(role_type)
    role_type = role_type.is_a?(String) ? BizTxnPartyRoleType.iid(role_type) : role_type

    biz_txn_party_role = biz_txn_party_roles.where(:biz_txn_party_role_type_id => role_type.id).first

    if biz_txn_party_role
      biz_txn_party_role.party
    end
  end

  def create_dependent_txns
    #Template Method
  end

  def to_label
    "#{description}"
  end

  def to_s
    "#{description}"
  end

  def to_data_hash
    to_hash(only: [:id,
                   :description,
                   :entered_date,
                   :post_date,
                   :external_identifier,
                   :external_id_source,
                   :created_at,
                   :updated_at])
  end

end
