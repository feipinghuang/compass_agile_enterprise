class OnlineDocumentSection < WebsiteSection
  attr_protected :created_at, :updated_at

  has_one :documented_item, :dependent => :destroy
  delegate :content, :to => :documented_item, :prefix => true
  delegate :published_content, :to => :documented_item, :prefix => true

  def documented_item_content_html
    documented_item_content.body_html
  rescue
    nil
  end

  def documented_item_published_content_html(active_publication)
    documented_item_published_content(active_publication).body_html
  rescue
    nil
  end

  def copy(title=nil, copy_children=false, created_by=nil)
    new_section = OnlineDocumentSection.new

    new_section.title = title.nil? ? self.title : title
    new_section.layout = self.layout
    new_section.in_menu = self.in_menu
    new_section.use_markdown = self.use_markdown
    new_section.render_base_layout = self.render_base_layout
    new_section.website_id = self.website_id

    new_section.save!

    # copy documented content
    documented_item = DocumentedItem.where('online_document_section_id = ?', self.id).first
    documented_content = DocumentedContent.find(documented_item.documented_content_id)
    new_documented_content = documented_content.dup

    # clear out internal identifier
    new_documented_content.internal_identifier = nil

    new_documented_content.created_by = created_by
    new_documented_content.save!
    DocumentedItem.create!(:documented_content_id => new_documented_content.id, :online_document_section_id => new_section.id)

    if copy_children
      self.children.each do |child_section|
        new_child_section = child_section.copy(nil, copy_children, created_by)
        new_child_section.move_to_child_of(new_section)
      end
    end

    new_section
  end

  def build_section_hash
    {
      :name => self.title,
      :has_layout => false,
      :use_markdown => self.use_markdown,
      :type => self.class.to_s,
      :in_menu => self.in_menu,
      :path => self.path,
      :permalink => self.permalink,
      :internal_identifier => self.internal_identifier,
      :position => self.position,
      :online_document_sections => self.children.each.map { |child| child.build_section_hash },
      :articles => [],
      :documented_item => {
        :name => documented_item_content.title,
        :display_title => documented_item_content.display_title,
        :internal_identifier => documented_item_content.internal_identifier
      }
    }
  end

end
