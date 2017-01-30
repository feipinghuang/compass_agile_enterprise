class Component < Content

  before_save :check_internal_indentifier

  def self.to_data_hash
    all.inject({}) do | data, component |
      data[component.component_type] = [ ] unless data[component.component_type].present?
      data[component.component_type] << component.to_data_hash
      data
    end
  end

  def to_param
    permalink
  end

  def check_internal_indentifier
    self.internal_identifier = self.permalink if self.internal_identifier.blank?
  end

  def combobox_display_value
    "#{title} (#{internal_identifier})"
  end

  def to_data_hash
    {
      iid: self.internal_identifier,
      title: self.title,
      thumbnail: self.custom_data["thumbnail"],
      url: self.custom_data["url"],
      height: self.custom_data["height"]
    }
  end

  def component_type
    custom_data["component_type"]
  end

end
