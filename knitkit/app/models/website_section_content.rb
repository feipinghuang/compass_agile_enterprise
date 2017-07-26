class WebsiteSectionContent < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :website_section
  belongs_to :content
end
