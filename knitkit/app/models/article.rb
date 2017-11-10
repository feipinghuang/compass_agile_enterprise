class Article < Content
  attr_protected :created_at, :updated_at

  before_save :check_internal_indentifier

  def to_param
    permalink
  end

  def check_internal_indentifier
    self.internal_identifier = self.permalink if self.internal_identifier.blank?
  end

  def combobox_display_value
    "#{title} (#{internal_identifier})"
  end
end
