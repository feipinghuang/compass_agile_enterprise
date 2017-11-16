class AttributeValue < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :attributed_record, :polymorphic => true
  belongs_to :attribute_type

  validates_format_of :value, :with => /\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\z/, :if => :is_date?
  after_destroy :remove_unused_types

  def is_date?
    self.attribute_type.data_type == 'Date' ? true : false
  end

  def value_as_data_type
    data_type = self.attribute_type.data_type

    case data_type
    when "Date"
      self.value.to_date
    when "Boolean"
      self.value == "true" ? true : false
    when "Int"
      self.value.to_i
    when "Float"
      self.value.to_f
    else
      self.value
    end
  end

  def value_as_date
    if self.is_date?
      self.value.to_date
    else
      raise "value is not a Date or is not properly formated"
    end
  end

  def remove_unused_types
    AttributeType.includes(:attribute_values).joins('LEFT OUTER JOIN attribute_values on attribute_values.attribute_type_id = attribute_types.id').where('attribute_values.id is null').each do |type|
      type.destroy
    end
  end
end
