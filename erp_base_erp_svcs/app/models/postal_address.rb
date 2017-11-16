#  create_table :postal_addresses do |t|
#    t.column :address_line_1, :string
#    t.column :address_line_2, :string
#    t.column :city, :string
#    t.column :state, :string
#    t.column :zip, :string
#    t.column :country, :string
#    t.column :description, :string
#    t.column :geo_country_id, :integer
#    t.column :geo_zone_id, :integer
#    t.timestamps
#  end
#  add_index :postal_addresses, :geo_country_id
#  add_index :postal_addresses, :geo_zone_id

class PostalAddress < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  is_contact_mechanism

  belongs_to :geo_country
  belongs_to :geo_zone

  # Get dba_organzation info eventually going to be tenant
  def dba_organization
    self.contact.dba_organization
  end
  alias :tenant :dba_organization

  def summary_line
    "#{description} : #{address_line_1}, #{city}"
  end

  def to_label(&block)
    if block_given?
      block.call(self)
    else
      "#{description} : #{to_s}"
    end
  end

  def to_s
    "#{address_line_1}, #{city}, #{state} #{zip}"
  end

  def zip_eql_to?(zip)
    self.zip.downcase.gsub(/[^a-zA-Z0-9]/, "")[0..4] == zip.to_s.downcase.gsub(/[^a-zA-Z0-9]/, "")[0..4]
  end

  def to_data_hash
    to_hash(only: [
              :id,
              :address_line_1,
              :address_line_2,
              :city,
              :state,
              :zip,
              :country,
              :description,
              :created_at,
              :updated_at
            ],
            name: self.try(:contact).try(:party).try(:description),
            is_primary: self.try(:contact).try(:is_primary)
            )
  end

end
