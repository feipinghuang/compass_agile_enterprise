class Component < Content

  before_save :check_internal_indentifier

  def check_internal_indentifier
    self.internal_identifier = self.permalink if self.internal_identifier.blank?
  end

  def to_data_hash(theme=nil)
    data = to_hash(only: [:id, :internal_identifier, :title, :component_type])

    if theme
      data['thumbnail_url'] = File.join(ErpTechSvcs::Config.installation_url, theme.url, 'images', 'content_blocks', self.internal_identifier)
    else
      data['thumbnail_url'] = File.join(ErpTechSvcs::Config.installation_url, 'images', 'content_blocks', self.internal_identifier)
    end

    data
  end

end
