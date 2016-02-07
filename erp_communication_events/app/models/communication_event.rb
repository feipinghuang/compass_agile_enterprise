# create_table :communication_events do |t|
#   t.integer  :from_contact_mechanism_id
#   t.string   :from_contact_mechanism_type
#
#   t.integer  :to_contact_mechanism_id
#   t.string   :to_contact_mechanism_type
#
#   t.integer  :role_type_id_from
#   t.integer  :role_type_id_to
#
#   t.integer  :party_id_from
#   t.integer  :party_id_to
#
#   t.string   :short_description
#   t.integer  :case_id
#   t.datetime :start_at
#   t.datetime :end_at
#   t.string   :notes
#   t.string   :external_identifier
#   t.string   :external_id_source
#
#   t.timestamps
# end
#
# add_index :communication_events, :status_type_id
# add_index :communication_events, :case_id
# add_index :communication_events, :role_type_id_from
# add_index :communication_events, :role_type_id_to
# add_index :communication_events, :party_id_from
# add_index :communication_events, :party_id_to
# add_index :communication_events, [:to_contact_mechanism_id, :to_contact_mechanism_type], :name => 'to_contact_mech_idx'
# add_index :communication_events, [:from_contact_mechanism_id, :from_contact_mechanism_type], :name => 'from_contact_mech_idx'

class CommunicationEvent < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :from_party, :class_name => 'Party', :foreign_key => 'party_id_from'
  belongs_to :to_party ,  :class_name => 'Party', :foreign_key => 'party_id_to'
  
  belongs_to :from_role , :class_name => 'RoleType', :foreign_key => 'role_type_id_from'
  belongs_to :to_role ,   :class_name => 'RoleType', :foreign_key => 'role_type_id_to'

  belongs_to :from_contact_mechanism, :polymorphic => true
  belongs_to :to_contact_mechanism, :polymorphic => true

  has_and_belongs_to_many :comm_evt_purpose_types, :join_table => 'comm_evt_purposes'

  has_tracked_status

  def to_label
    "#{short_description}"
  end  

end
