class InventoryEntry < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :inventory_entry_record, :polymorphic => true
  belongs_to :product_type
  has_one :classification, :as => :classification, :class_name => 'CategoryClassification'
  has_many :prod_instance_inv_entries
  has_many :product_instances, :through => :prod_instance_inv_entries do
    def available
      includes([:prod_availability_status_type]).where('prod_availability_status_types.internal_identifier = ?', 'available')
    end

    def sold
      includes([:prod_availability_status_type]).where('prod_availability_status_types.internal_identifier = ?', 'sold')
    end
  end
  has_many :inventory_entry_locations
  has_many :facilities, :through => :inventory_entry_locations
  belongs_to :unit_of_measurement

  alias_method :storage_facilities, :facilities

  delegate :description, :sku, :unit_of_measurement, :to => :product_type, :prefix => true

  def current_location
    self.inventory_entry_locations
  end

  def current_storage_facility
    inventory_entry_locations.last.facility
  end

  def current_storage_facility=(facility)
    location = InventoryEntryLocation.new
    location.facility = facility
    location.inventory_entry = self
    location.save
  end

  def current_storage_facility_id=(facility_id)
    location = InventoryEntryLocation.new
    location.facility_id = facility_id
    location.inventory_entry = self
    location.save
  end

  def to_data_hash
    data = to_hash(only: [
                       :id,
                       :description,
                       :number_available,
                       :number_in_stock,
                       :created_at,
                       :updated_at
                   ],
                   sku: get_sku,
                   product_type: try(:product_type).try(:to_data_hash))

    if get_uom
      data[:unit_of_measurement] = get_uom.to_data_hash
    else
      data[:unit_of_measurement] = nil
    end

    if current_storage_facility
      data[:inventory_storage_facility] = current_storage_facility.to_data_hash
    else
      data[:inventory_storage_facility] = nil
    end

    data
  end

  def to_label
    "#{description}"
  end

  def get_sku
    if self.sku.blank?
      self.product_type_sku
    else
      self.sku
    end
  end

  def get_uom
    if self.unit_of_measurement.nil?
      self.product_type_unit_of_measurement
    else
      self.unit_of_measurement
    end
  end

end
