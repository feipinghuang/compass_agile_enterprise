class WebsiteSection < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  after_create :update_paths # must happen after has_roles so that after_create :save_secured_model fires first
  before_save :update_path, :check_internal_identifier

  extend FriendlyId
  friendly_id :title, :use => [:slugged, :scoped], :slug_column => :permalink, :scope => [:website_id, :parent_id]

  def should_generate_new_friendly_id?
    new_record?
  end

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods
  acts_as_versioned :table_name => :website_section_versions, :non_versioned_columns => %w{parent_id lft rgt}
  can_be_published

  protected_with_capabilities

  belongs_to :website
  has_many :website_section_contents, :dependent => :destroy
  has_many :contents, :through => :website_section_contents

  validates :title, :presence => {:message => 'Title cannot be blank'}
  validates_uniqueness_of :permalink, :scope => [:website_id, :parent_id]
  validates_uniqueness_of :internal_identifier, :scope => [:website_id, :parent_id], :case_sensitive => false

  KNIT_KIT_ROOT = Knitkit::Engine.root.to_s
  WEBSITE_SECTIONS_TEMP_LAYOUT_PATH = "#{Knitkit::Engine.root.to_s}/app/views/knitkit/website_sections"

  @@types = ['Page']
  cattr_reader :types

  class << self
    def register_type(type)
      @@types << type
      @@types.uniq!
    end
  end

  def copy(title=nil, copy_articles=false, copy_children=false)
    new_section = WebsiteSection.new

    new_section.title = title.nil? ? self.title : title
    new_section.layout = self.layout
    new_section.in_menu = self.in_menu
    new_section.render_base_layout = self.render_base_layout
    new_section.website_id = self.website_id

    new_section.save!

    # copy attached articles
    if copy_articles
      self.articles.readonly(false).each do |article|
        article.website_sections << new_section
        article.save
      end
    end

    if copy_children
      self.children.each do |child_section|
        new_child_section = child_section.copy(nil, copy_articles, copy_children)
        new_child_section.move_to_child_of(new_section)
      end
    end

    new_section
  end

  def is_blog?
    self.is_a?(Blog) || self.attributes['type'] == 'Blog'
  end

  def secure
    capability = self.add_capability(:view)
    roles = ['admin', 'website_author', self.website.website_role_iid]
    roles.each do |role|
      role = SecurityRole.find_by_internal_identifier(role)
      role.add_capability(capability)
    end
  end

  def iid
    internal_identifier
  end

  def articles
    Article.find_by_section_id(self.id)
  end

  def website
    website_id.nil? ? self.parent.website : Website.find(website_id)
  end

  def render_base_layout?
    render_base_layout
  end

  def positioned_children
    children.order('position')
  end

  def children_in_menu
    positioned_children.where('in_menu = ?', true)
  end

  def paths
    all_paths = [self.path]
    all_paths | self.descendants.collect(&:path)
  end

  def child_by_path(path)
    self.descendants.detect { |child| child.path == path }
  end

  def type
    read_attribute(:type) || 'Page'
  end

  def is_section?
    ['Page', 'Blog'].include? type
  end

  def display_in_menu?
    self.in_menu
  end

  def is_secured?
    self.protected_with_capability?('view')
  end

  def is_document_section?
    type == 'OnlineDocumentSection'
  end

  def create_layout
    self.layout = IO.read(File.join(WEBSITE_SECTIONS_TEMP_LAYOUT_PATH, "index.html.erb"))
    self.save
  end

  def get_published_layout(active_publication)
    layout_content = nil

    published_website_id = active_publication.id
    published_element = PublishedElement.includes([:published_website]).where('published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ?', published_website_id, self.id, 'WebsiteSection').first
    unless published_element.nil?
      layout_content = WebsiteSection::Version.where('version = ? and website_section_id = ?', published_element.version, published_element.published_element_record_id).first.layout
    end
    layout_content
  end

  def get_tags
    get_topics
  end

  def get_topics
    # leaving this here for reference until we're sure the built in method tag_counts_on does what we need
    # sql = "SELECT tags.*, taggings.tags_count AS count FROM \"tags\"
    #               JOIN (SELECT taggings.tag_id, COUNT(taggings.tag_id) AS tags_count FROM \"taggings\"
    #                     INNER JOIN contents ON contents.id = taggings.taggable_id AND contents.type = 'Article'
    #                     INNER JOIN website_section_contents ON contents.id=website_section_contents.content_id
    #                     WHERE (taggings.taggable_type = 'Content' AND taggings.context = 'tags')
    #                     AND website_section_contents.website_section_id=#{self.id}
    #                     GROUP BY taggings.tag_id HAVING COUNT(*) > 0 AND COUNT(taggings.tag_id) > 0)
    #                     AS taggings ON taggings.tag_id = tags.id
    #               ORDER BY tags.name ASC"
    # ActsAsTaggableOn::Tag.find_by_sql(sql)

    self.contents.tag_counts_on(:tags).sort_by { |t| t.name }
  end

  def update_path!
    new_path = build_path
    self.path = new_path unless self.path == new_path
    self.save
  end

  def build_section_hash
    section_hash = {
        :name => self.title,
        :has_layout => !self.layout.blank?,
        :type => self.class.to_s,
        :in_menu => self.in_menu,
        :articles => [],
        :roles => self.roles.collect(&:internal_identifier),
        :path => self.path,
        :permalink => self.permalink,
        :internal_identifier => self.internal_identifier,
        :render_base_layout => self.render_base_layout,
        :position => self.position,
        :sections => self.children.each.map { |child| child.build_section_hash }
    }

    self.contents.each do |content|
      content_area = content.content_area_by_website_section(self)
      position = content.position_by_website_section(self)
      section_hash[:articles] << {
          :name => content.title,
          :tag_list => content.tag_list.join(', '),
          :content_area => content_area,
          :position => position,
          :display_title => content.display_title,
          :internal_identifier => content.internal_identifier
      }
    end

    section_hash
  end


  protected

  def update_path
    if permalink_changed?
      new_path = build_path
      self.path = new_path unless self.path == new_path
    end
  end

  def build_path
    "/#{self_and_ancestors.map(&:permalink).join('/')}"
  end

  def update_paths
    if parent_id
      move_to_child_of(WebsiteSection.find(parent_id))
      website.sections.update_paths!
    end
  end

  def check_internal_identifier
    self.internal_identifier = self.permalink if self.internal_identifier.blank?
  end

  private

  def self.get_published_version(active_publication, content)
    content_version = nil
    published_website_id = active_publication.id
    published_element = PublishedElement.includes([:published_website]).where('published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ?', published_website_id, content.id, 'Content').first
    unless published_element.nil?
      content_version = Content::Version.where('version = ? and content_id = ?', published_element.version, published_element.published_element_record_id).first
    end
    content_version
  end

end


