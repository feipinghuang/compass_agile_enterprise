class WebsiteSectionContent < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :website_section
  belongs_to :content

  def to_data_hash
    to_hash(only: [:id, :website_section_id, :content_id, :position])
  end

  def build_section_content_hash
    {
      id: id,
      position: position,
      column: col
    }
  end

end
