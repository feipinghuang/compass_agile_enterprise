#### Table Definition ###########################
#  create_table :financial_txns do |t|
#    t.integer :money_id
#    t.date    :apply_date
#
#    t.timestamps
#  end
#################################################

class FinancialTxn < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_biz_txn_event
  can_be_generated

  belongs_to :money, :dependent => :destroy

  class << self
    # Filter records
    #
    # @param filters [Hash] a hash of filters to be applied,
    # @param statement [ActiveRecord::Relation] the query being built
    # @return [ActiveRecord::Relation] the query being built
    def apply_filters(filters, statement=nil)
      unless statement
        statement = FinancialTxn
      end

      statement = statement.joins(:biz_txn_event)

      biz_txn_event_tbl = BizTxnEvent.arel_table

      # filter by query which will filter on description
      if filters[:query]
        statement = statement.where('biz_txn_events.description like ?', "%#{filters[:query].strip}%")
      end

      # filter by WorkEffortType
      unless filters[:biz_txn_type_iids].blank?
        statement = statement.where(biz_txn_events: {biz_txn_type_id: BizTxnType.where(internal_identifier: filters[:biz_txn_type_iids])})
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

      joins(:biz_txn_event)
          .joins("inner join biz_txn_party_roles on biz_txn_party_roles.biz_txn_event_id = biz_txn_events.id")
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
      statement = joins(:biz_txn_event)
                      .joins("inner join biz_txn_party_roles on biz_txn_party_roles.biz_txn_event_id = biz_txn_events.id")
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

  # converts this record a hash data representation
  #
  # @return [Hash]
  def to_data_hash
    data = to_hash(only: [:id, :description, :apply_date])

    data[:amount] = self.money.nil? ? 0 : self.money.amount

    data
  end

end
