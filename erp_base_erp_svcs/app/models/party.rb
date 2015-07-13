class Party < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_notes

  has_many :contacts, :dependent => :destroy
  has_many :created_notes, :class_name => 'Note', :foreign_key => 'created_by_id'
  belongs_to :business_party, :polymorphic => true

  has_many :party_roles, :dependent => :destroy #role_types
  has_many :role_types, :through => :party_roles

  after_destroy :destroy_business_party, :destroy_party_relationships

  attr_reader :relationships
  attr_writer :create_relationship

  class << self
    def find_by_email(email, contact_purpose=nil)
      if contact_purpose
        self.joins(:contacts => [:contact_purposes])
            .joins("INNER JOIN email_addresses on email_addresses.id = contacts.contact_mechanism_id
                and contacts.contact_mechanism_type = 'EmailAddress'")
            .where('contact_mechanism_type = ?', 'EmailAddress')
            .where('contact_purposes.internal_identifier = ?', contact_purpose)
            .where('email_address = ?', email).readonly(false).first
      else
        self.joins(:contacts)
            .joins("INNER JOIN email_addresses on email_addresses.id = contacts.contact_mechanism_id
                and contacts.contact_mechanism_type = 'EmailAddress'")
            .where('contact_mechanism_type = ?', 'EmailAddress')
            .where('email_address = ?', email).readonly(false).first
      end
    end
  end

  # helper method to get dba_organization related to this party
  def dba_organization
    find_related_parties_with_role('dba_org').first
  end

  def child_dba_organizations(dba_orgs=[])
    PartyRelationship.
        where('party_id_to = ?', id).
        where('role_type_id_to' => RoleType.iid('dba_org')).each do |party_reln|

      if party_reln.from_party && party_reln.from_party.has_role_type?('dba_org')
        dba_orgs.push(party_reln.from_party)
        party_reln.from_party.child_dba_organizations(dba_orgs)
      end
    end

    dba_orgs.uniq
  end

  def parent_dba_organizations(dba_orgs=[])
    PartyRelationship.
        where('party_id_from = ?', id).
        where('role_type_id_to' => RoleType.iid('dba_org')).each do |party_reln|

      if party_reln.to_party
        dba_orgs.push(party_reln.to_party)
        party_reln.to_party.parent_dba_organizations(dba_orgs)
      end
    end

    dba_orgs.uniq
  end

  # Gathers all party relationships that contain this particular party id
  # in either the from or to side of the relationship.
  def relationships
    @relationships ||= PartyRelationship.where('party_id_from = ? or party_id_to = ?', id, id)
  end

  def to_relationships
    @relationships ||= PartyRelationship.where('party_id_to = ?', id)
  end

  def from_relationships
    @relationships ||= PartyRelationship.where('party_id_from = ?', id)
  end

  def find_related_parties_with_role(role_type_iid)
    Party.joins(:party_roles).joins("inner join party_relationships on (party_id_from = #{id} and parties.id = party_relationships.party_id_to)")
        .where(PartyRole.arel_table[:role_type_id].eq(RoleType.iid(role_type_iid).id))
        .where(Party.arel_table[:id].not_eq(id))
  end

  def find_relationships_by_type(relationship_type_iid)
    PartyRelationship.includes(:relationship_type).
        where('party_id_from = ? or party_id_to = ?', id, id).
        where('relationship_types.internal_identifier' => relationship_type_iid.to_s)
  end

  # Creates a new PartyRelationship for this particular
  # party instance.
  def create_relationship(description, to_party_id, reln_type)
    PartyRelationship.create(:description => description,
                             :relationship_type => reln_type,
                             :party_id_from => id,
                             :from_role => reln_type.valid_from_role,
                             :party_id_to => to_party_id,
                             :to_role => reln_type.valid_to_role)
  end

  # Callbacks
  def destroy_business_party
    if self.business_party
      self.business_party.destroy
    end
  end

  def destroy_party_relationships
    PartyRelationship.destroy_all("party_id_from = #{id} or party_id_to = #{id}")
  end

  def add_role_type(role)
    role = role.is_a?(RoleType) ? role : RoleType.iid(role)

    PartyRole.create(party: self, role_type: role)
  end

  def has_role_type?(*passed_roles)
    result = false
    passed_roles.flatten!
    passed_roles.each do |role|
      role_iid = role.is_a?(RoleType) ? role.internal_identifier : role.to_s

      PartyRole.where(party_id: self.id).each do |party_role|
        result = true if (party_role.role_type.internal_identifier == role_iid)
        break if result
      end

    end
    result
  end

  def has_phone_number?(phone_number)
    result = nil
    self.contacts.each do |c|
      if c.contact_mechanism_type == 'PhoneNumber'
        if c.contact_mechanism.phone_number == phone_number
          result = true
        end
      end
    end
    result
  end

  def has_zip_code?(zip)
    result = nil
    self.contacts.each do |c|
      if c.contact_mechanism_type == 'PostalAddress'
        if c.contact_mechanism.zip == zip
          result = true
        end
      end
    end
    result
  end

  # Alias for to_s
  def to_label
    to_s
  end

  def to_s
    "#{description}"
  end

  # method to convert party data to hash
  def to_data_hash
    hash = {
        server_id: id,
        description: description,
        created_at: created_at,
        updated_at: updated_at,
        business_party_type: business_party.class.name
    }

    # get business party data
    if business_party
      if business_party.is_a?(Individual)
        hash.merge!({
                        first_name: business_party.current_first_name,
                        last_name: business_party.current_last_name,
                        middle_name: business_party.current_middle_name,
                        gender: business_party.gender
                    })
      else
        hash.merge!({
                        tax_id_number: business_party.tax_id_number
                    })
      end
    end

    hash
  end

  #************************************************************************************************
  #** Contact Methods
  #************************************************************************************************

  # check if party has contact with purpose
  def has_contact?(contact_mechanism_klass, contact_purpose)
    !contact_mechanisms_to_hash(contact_mechanism_klass, [contact_purpose]).empty?
  end

  def phone_numbers_to_hash(contact_purposes=nil)
    contact_mechanisms_to_hash(PhoneNumber, contact_purposes)
  end

  def email_addresses_to_hash(contact_purposes=nil)
    contact_mechanisms_to_hash(EmailAddress, contact_purposes)
  end

  def postal_addresses_to_hash(contact_purposes=nil)
    contact_mechanisms_to_hash(PostalAddress, contact_purposes)
  end

  def contact_mechanisms_to_hash(contact_mechanism_klass, contact_purposes=nil)
    contact_mechanisms_data = []

    if contact_purposes && contact_purposes.is_a?(String)
      contact_purposes = [contact_purposes]
    end

    if contact_purposes
      contact_purposes.each do |contact_purpose|
        contact_mechanism = find_contact_mechanisms_with_purpose(contact_mechanism_klass, contact_purpose)

        unless contact_mechanism.empty?
          contact_mechanism.collect do |item|
            data = item.to_data_hash
            data[:contact_purpose] = contact_purpose

            contact_mechanisms_data.push(data)
          end
        end
      end
    else
      contact_mechanisms = find_all_contacts_by_contact_mechanism(contact_mechanism_klass)
      contact_mechanisms.each do |contact_mechanism|
        data = contact_mechanism.to_data_hash
        data[:contact_purpose] = contact_mechanism.contact.contact_purpose.first.internal_identifier

        contact_mechanisms_data.push(data)
      end
    end

    contact_mechanisms_data
  end

  def primary_phone_number
    contact_mechanism = nil

    contact = self.get_primary_contact(PhoneNumber)
    contact_mechanism = contact.contact_mechanism unless contact.nil?

    contact_mechanism
  end

  alias primary_phone primary_phone_number

  def primary_phone_number=(phone_number)
    self.set_primary_contact(PhoneNumber, phone_number)
  end

  alias primary_phone= primary_phone_number=

  def primary_email_address
    contact_mechanism = nil

    contact = self.get_primary_contact(EmailAddress)
    contact_mechanism = contact.contact_mechanism unless contact.nil?

    contact_mechanism
  end

  alias primary_email primary_email_address

  def primary_email_address=(email_address)
    self.set_primary_contact(EmailAddress, email_address)
  end

  alias primary_email= primary_email_address=

  def primary_postal_address
    contact_mechanism = nil

    contact = self.get_primary_contact(PostalAddress)
    contact_mechanism = contact.contact_mechanism unless contact.nil?

    contact_mechanism
  end

  alias primary_address primary_postal_address

  def primary_postal_address=(postal_address)
    self.set_primary_contact(PostalAddress, postal_address)
  end

  alias primary_address= primary_postal_address=

  def set_primary_contact(contact_mechanism_class, contact_mechanism_instance)
    # set is_primary to false for any current primary contacts of this type
    primary_contact_mechanism = get_primary_contact(contact_mechanism_class)
    if primary_contact_mechanism
      primary_contact_mechanism.is_primary = false
      primary_contact_mechanism.save
    end

    contact_mechanism_instance.is_primary = true
    contact_mechanism_instance.save

    contact_mechanism_instance
  end

  def get_primary_contact(contact_mechanism_class)
    table_name = contact_mechanism_class.name.tableize

    self.contacts.joins("inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.name}'")
        .where('contacts.is_primary = ?', true).readonly(false).first
  end

  # find first contact mechanism with purpose
  def find_contact_mechanism_with_purpose(contact_mechanism_class, contact_purpose)
    contact = self.find_contact_with_purpose(contact_mechanism_class, contact_purpose)

    contact.contact_mechanism unless contact.nil?
  end

  # find all contact mechanisms with purpose
  def find_contact_mechanisms_with_purpose(contact_mechanism_class, contact_purpose)
    contacts = self.find_contacts_with_purpose(contact_mechanism_class, contact_purpose)

    contacts.empty? ? [] : contacts.collect(&:contact_mechanism)
  end

  # find first contact with purpose
  def find_contact_with_purpose(contact_mechanism_class, contact_purpose)
    #if a symbol or string was passed get the model
    unless contact_purpose.is_a? ContactPurpose
      contact_purpose = ContactPurpose.find_by_internal_identifier(contact_purpose.to_s)
    end

    self.find_contact(contact_mechanism_class, nil, [contact_purpose])
  end

  # find all contacts with purpose
  def find_contacts_with_purpose(contact_mechanism_class, contact_purpose)
    #if a symbol or string was passed get the model
    unless contact_purpose.is_a? ContactPurpose
      contact_purpose = ContactPurpose.find_by_internal_identifier(contact_purpose.to_s)
    end

    self.find_contacts(contact_mechanism_class, nil, [contact_purpose])
  end

  # find all contacts by contact mechanism
  def find_all_contacts_by_contact_mechanism(contact_mechanism_class)
    table_name = contact_mechanism_class.name.tableize

    contacts = self.contacts.joins("inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.name}'")

    contacts.collect(&:contact_mechanism)
  end

  # find first contact
  def find_contact(contact_mechanism_class, contact_mechanism_args={}, contact_purposes=[])
    find_contacts(contact_mechanism_class, contact_mechanism_args, contact_purposes).first
  end

  # find all contacts
  def find_contacts(contact_mechanism_class, contact_mechanism_args={}, contact_purposes=[])
    table_name = contact_mechanism_class.name.tableize

    query = self.contacts.joins("inner join #{table_name} on #{table_name}.id = contact_mechanism_id and contact_mechanism_type = '#{contact_mechanism_class.name}'
                                   inner join contact_purposes_contacts on contact_purposes_contacts.contact_id = contacts.id
                                   and contact_purposes_contacts.contact_purpose_id in (#{contact_purposes.collect { |item| item.attributes["id"] }.join(',')})")

    contact_mechanism_args.each do |key, value|
      next if key == 'updated_at' or key == 'created_at' or key == 'id' or key == 'is_primary'
      query = query.where("#{table_name}.#{key} = ?", value) unless value.nil?
    end unless contact_mechanism_args.nil?

    query
  end

  # looks for contacts matching on value and purpose
  # if a contact exists, it updates, if not, it adds it
  def add_contact(contact_mechanism_class, contact_mechanism_args={}, contact_purposes=[])
    is_primary = contact_mechanism_args['is_primary']
    contact_purposes = [contact_purposes] if !contact_purposes.kind_of?(Array) # gracefully handle a single purpose not in an array

    contact_mechanism_args.delete_if { |k, v| ['created_at', 'updated_at', 'is_primary'].include? k.to_s }
    contact_mechanism = contact_mechanism_class.new(contact_mechanism_args)
    contact_mechanism.contact.party = self
    contact_purposes.each do |contact_purpose|
      if contact_purpose.is_a?(String)
        contact_mechanism.contact.contact_purposes << ContactPurpose.iid(contact_purpose)
      else
        contact_mechanism.contact.contact_purposes << contact_purpose
      end
    end
    contact_mechanism.contact.save
    contact_mechanism.save

    set_primary_contact(contact_mechanism_class, contact_mechanism) if is_primary

    contact_mechanism
  end

  # tries to update contact by purpose
  # if contact doesn't exist, it adds it
  def update_or_add_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
    contact_mechanism = update_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)

    unless contact_mechanism
      contact_mechanism = add_contact(contact_mechanism_class, contact_mechanism_args, [contact_purpose])
    end

    contact_mechanism
  end

  # looks for a contact matching on purpose
  # if it exists, it updates it, if not returns false
  def update_contact_with_purpose(contact_mechanism_class, contact_purpose, contact_mechanism_args)
    contact = find_contact_with_purpose(contact_mechanism_class, contact_purpose)
    contact.nil? ? false : update_contact(contact_mechanism_class, contact, contact_mechanism_args)
  end

  def update_contact(contact_mechanism_class, contact, contact_mechanism_args)
    set_primary_contact(contact_mechanism_class, contact.contact_mechanism) if contact_mechanism_args[:is_primary] == true

    contact_mechanism_class.update(contact.contact_mechanism, contact_mechanism_args)

    contact.contact_mechanism
  end

  def get_contact_by_method(m)
    method_name = m.split('_')
    return nil if method_name.size < 3 or method_name.size > 4
    # handles 1 or 2 segment contact purposes (i.e. home or employment_offer)
    # contact mechanism must be 2 segments, (i.e. email_address, postal_address, phone_number)
    if method_name.size == 4
      purpose = method_name[0] + '_' + method_name[1]
      klass = method_name[2] + '_' + method_name[3]
    else
      purpose = method_name[0]
      klass = method_name[1] + '_' + method_name[2]
    end

    #constantize klass to make sure it exists and is loaded
    begin
      klass_const = klass.camelize.constantize
      contact_purpose = ContactPurpose.find_by_internal_identifier(purpose)
      if contact_purpose.nil?
        return nil
      else
        find_contact_mechanism_with_purpose(klass_const, contact_purpose)
      end
    rescue NameError
      return nil
    end

  end

  def respond_to?(m, include_private_methods = false)
    (super ? true : get_contact_by_method(m.to_s)) rescue super
  end

  def method_missing(m, *args, &block)
    if self.respond_to?(m)
      value = get_contact_by_method(m.to_s)
      (value.nil?) ? super : (return value)
    else
      super
    end
  end

  #************************************************************************************************
  #** End
  #************************************************************************************************
end
