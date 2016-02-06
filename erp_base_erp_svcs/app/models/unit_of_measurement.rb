# create_table :unit_of_measurements do |t|
#   t.string :description
#   t.string :domain
#   t.string :internal_identifier
#   t.string :comments
#   t.string :external_identifier
#   t.string :external_id_source
#
#   t.integer :lft
#   t.integer :rgt
#   t.integer :parent_id
#
#   t.timestamps
# end
#
# add_index :unit_of_measurements, :lft
# add_index :unit_of_measurements, :rgt
# add_index :unit_of_measurements, :parent_id

class UnitOfMeasurement < ActiveRecord::Base

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
                                PartyUnitOfMeasurement

  has_many :party_unit_of_measurements

  attr_accessible :description

  def to_data_hash
    to_hash(only: [:id,
                   :description,
                   :domain,
                   :internal_identifier,
                   :comments,
                   :external_identifier,
                   :external_id_source,
                   :created_at,
                   :updated_at])
  end

end