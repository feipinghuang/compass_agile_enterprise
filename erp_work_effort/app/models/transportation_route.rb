# create_table :transportation_routes do |t|
#
#   t.string :internal_identifier
#   t.string :description
#   t.string :comments
#
#   t.string :external_identifier
#   t.string :external_id_source
#
#   t.timestamps
# end

class TransportationRoute < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by
  has_party_roles
  has_tracked_status

  #declare array to related models
  attr_accessor :associated_records_array

  # This class instance variable is needed to hold the models linked within :associated_transportation_routes
  class << self;
    attr_accessor :associated_models
  end
  @associated_models = []

  # Needed for polymorophic relationship with other models
  has_many :associated_transportation_routes, :dependent => :destroy

  has_many :segments, :class_name => "TransportationRouteSegment", :after_add => :modify_stops, :dependent => :destroy
  has_many :stops, :class_name => "TransportationRouteStop", :dependent => :destroy

  #before we save this model make sure you save all the relationships.
  before_save do |record|
    record.send("associated_records").each do |reln_record|
      #handle STI get superclass class_name if not sub class of ActiveRecord::Base
      klass_name = (reln_record.class.superclass == ActiveRecord::Base) ? reln_record.class.name : reln_record.class.superclass.name
      conditions = "associated_record_id = #{reln_record.id} and associated_record_type = '#{klass_name}'"
      exisiting_record = record.send("associated_transportation_routes").where(conditions).first

      if exisiting_record.nil?
        values_hash = {}
        values_hash["#{record.class.name.underscore}_id"] = record.id
        values_hash["associated_record_type"] = klass_name
        values_hash["associated_record_id"] = reln_record.id

        AssociatedTransportationRoute.create(values_hash)
      end
    end
  end

  class << self
    def open_entries
      joins(:segments)
          .where(transportation_routes: {manual_entry: false})
          .where(transportation_route_segments: {actual_arrival: nil})
    end

    #
    # Scoping
    #

    #
    # scoping helpers
    #

    # scope by dba organization
    #
    # @param dba_organization [Party] dba organization to scope by
    #
    # @return [ActiveRecord::Relation]
    def scope_by_dba_organization(dba_organization)
      scope_by_party(dba_organization, {role_types: ['dba_org']})
    end

    alias scope_by_dba scope_by_dba_organization

    # scope by work efforts assigned to the passed user
    #
    # @param user [User] user to look for assignments
    # @param options [Hash] options to apply to this scope
    # @option options [Array] :role_types role types to include in the scope
    #
    # @return [ActiveRecord::Relation]
    def scope_by_user(user, options={})
      scope_by_party(user.party, options)
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
      table_alias = String.random

      if options[:role_types]
        joins("inner join entity_party_roles as #{table_alias} on #{table_alias}.entity_record_type = 'TransportationRoute'
                                     and #{table_alias}.entity_record_id = transportation_routes.id and
                                     #{table_alias}.role_type_id in (#{RoleType.find_child_role_types(options[:role_types]).collect(&:id).join(',')})
                                     and #{table_alias}.party_id in (#{Party.select('id').where(id: party).to_sql})")

      else
        joins("inner join entity_party_roles as #{table_alias} on #{table_alias}.entity_record_type = 'TransportationRoute'
                                     and #{table_alias}.entity_record_id = transportation_routes.id
                                     and #{table_alias}.party_id in (#{Party.select('id').where(id: party).to_sql})")
      end
    end
  end

  # Gets all associated records (of any class) tied to this route
  def associated_records
    #used the declared instance variable array
    records = self.send("associated_records_array")
    records = records || []
    self.class.associated_models.each do |model|
      records = records | self.send(model.to_s)
    end

    #set it back to the instance variable
    self.send("associated_records_array=", records)

    records
  end

  # Ties a segment's from/to stops to its route, and then forces a reload of the route's stops array from its cached value
  def modify_stops(segment)
    stops = []
    stops << segment.from_stop << segment.to_stop

    stops.each do |stop|
      unless stop.nil? or stop.route == self
        stop.route = self
        stop.save
      end
    end

    # Force reload of the stops array since it has changed
    self.stops(true)
  end

  def to_data_hash
    data = to_hash(only: [:id, :internal_identifier, :description,
                          :comments, :created_at, :updated_at])

    data[:transportation_route_segments] = segments.collect { |item| item.to_data_hash }

    data
  end

end