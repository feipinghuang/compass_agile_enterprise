require 'will_paginate/array'

class Content < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  is_json :custom_data

  has_party_roles

  extend FriendlyId
  friendly_id :title, :use => [:slugged], :slug_column => :permalink

  def should_generate_new_friendly_id?
    new_record?
  end

  protected_with_capabilities

  acts_as_taggable
  acts_as_commentable
  acts_as_versioned :table_name => :content_versions do
    def excerpt_html
      if attributes['excerpt_html'].blank?
        HTML_Truncator.truncate(attributes['body_html'], 25)
      else
        attributes['excerpt_html']
      end
    end
  end

  can_be_published

  has_many :website_section_contents, :dependent => :destroy
  has_many :website_sections, :through => :website_section_contents
  belongs_to :created_by, :class_name => "User"
  belongs_to :updated_by, :class_name => "User"

  validates :type, :presence => {:message => 'Type cannot be blank'}
  validates_uniqueness_of :internal_identifier, :case_sensitive => false

  scope :header_components,  where("internal_identifier like '%header%'")
  scope :content_section_components, where("internal_identifier like '%content_section%'")
  scope :footer_components, where("internal_identifier like '%footer%'")

  def self.search(options = {})
    predicate = Content.includes([:website_sections])

    unless options[:section_unique_name].blank?
      predicate = predicate.where("website_sections.internal_identifier = ?", options[:section_unique_name])
    end

    unless options[:parent_id].blank?
      predicate = predicate.where("website_sections.id" => WebsiteSection.find(options[:parent_id]).self_and_descendants.collect(&:id))
    end

    unless options[:content_type].blank?
      predicate = predicate.where("website_sections.type = ?", options[:content_type])
    end

    unless options[:website_id].blank?
      predicate = predicate.where("website_sections.website_id = ?", options[:website_id])
    end

    predicate = predicate.where("(UPPER(contents.title) LIKE UPPER('%#{options[:query]}%')
                      OR UPPER(contents.excerpt_html) LIKE UPPER('%#{options[:query]}%')
                      OR UPPER(contents.body_html) LIKE UPPER('%#{options[:query]}%') )").order("contents.created_at DESC")

    if options[:page]
      predicate.paginate(:page => options[:page], :per_page => options[:per_page])
    else
      predicate.all
    end
  end

  def self.do_search(options = {})
    @results = Content.search(options)

    @search_results = build_search_results(@results)

    @page_results = WillPaginate::Collection.create(options[:page], options[:per_page], @results.total_entries) do |pager|
      pager.replace(@search_results)
    end

    @page_results
  end

  def self.find_by_section_id(website_section_id)
    Content.joins(:website_section_contents).where('website_section_id = ?', website_section_id).order("website_section_contents.position ASC, website_section_contents.created_at DESC")
  end

  def self.find_by_section_id_filtered_by_id(website_section_id, id_filter_list)
    Content.joins(:website_section_contents).where("website_section_id = ? AND contents.id IN (#{id_filter_list.join(',')})", website_section_id)
  end

  def self.find_published_by_section(active_publication, website_section)
    published_content = []
    contents = self.find_by_section_id(website_section.id)
    contents.each do |content|
      content = get_published_version(active_publication, content)
      published_content << content unless content.nil?
    end

    published_content
  end

  def self.find_published_by_section_with_tag(active_publication, website_section, tag)
    published_content = []
    id_filter_list = self.tagged_with(tag.name).collect { |t| t.id }
    contents = self.find_by_section_id_filtered_by_id(website_section.id, id_filter_list)
    contents.each do |content|
      content = get_published_version(active_publication, content)
      published_content << content unless content.nil?
    end

    published_content
  end

  def find_website_sections_by_site_id(website_id)
    self.website_sections.where('website_id = ?', website_id).all
  end

  def position(website_section_id)
    self.website_section_contents.find_by_website_section_id(website_section_id).position
  end

  def get_comments(limit)
    self.comments.recent.limit(limit).all
  end

  def update_content_area_and_position_by_section(section, content_area, position)
    website_section_content = WebsiteSectionContent.where('content_id = ? and website_section_id = ?', self.id, section.id).first
    unless website_section_content.nil?
      website_section_content.content_area = content_area
      website_section_content.position = position
      website_section_content.save
    end

    website_section_content
  end

  def content_area_by_website_section(section)
    content_area = nil
    unless WebsiteSectionContent.where('content_id = ? and website_section_id = ?', self.id, section.id).first.nil?
      content_area = WebsiteSectionContent.where('content_id = ? and website_section_id = ?', self.id, section.id).first.content_area
    end
    content_area
  end

  def position_by_website_section(section)
    position = nil
    unless WebsiteSectionContent.where('content_id = ? and website_section_id = ?', self.id, section.id).first.nil?
      position = WebsiteSectionContent.where('content_id = ? and website_section_id = ?', self.id, section.id).first.position
    end
    position
  end

  def assign_attribute_on_save
    super

    Article.find_by_internal_identifier(self.internal_identifier) ? attribute_type_description = "updated_by_role" : attribute_type_description = "created_by_role"

    if attribute_type_description == "created_by_role"
      user = self.created_by
    else
      user = User.find(self.versions.sort_by { |version| version.version }.reverse[0].created_by_id)
    end

    if user
      #keep only the attributes related to the most recent change for each attribute_type
      self.destroy_values_of_type attribute_type_description

      attribute_type = AttributeType.find_by_internal_identifier(attribute_type_description)
      attribute_type = AttributeType.create(:description => attribute_type_description, :data_type => "Text") unless attribute_type

      user.roles.each do |role|
        new_value = AttributeValue.new(:value => role.internal_identifier)
        attribute_type.attribute_values << new_value
        self.attribute_values << new_value
        new_value.save
      end
    end
  end

  def is_published?
    !PublishedElement.where('published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.id, 'Content', self.version).first.nil?
  end

  def pretty_tag_list
    self.tag_list.join(", ")
  end

  def to_data_hash
      data = {
          iid: self.internal_identifier,
          img_src: self.custom_data["image_src"],
          html_src: self.custom_data["html_src"],
          height: self.custom_data["height"]
      }
  end

  protected

  def self.build_search_results(results)
    # and if it is a blog get the article link and title
    results_array = []
    results.each do |content|
      section = content.website_sections.first

      results_hash = {}
      if section.attributes['type'] == 'Blog'
        results_hash[:link] = section.path + '/' + content.permalink
        results_hash[:title] = content.title
      else
        results_hash[:link] = section.path
        results_hash[:title] = section.title
      end
      results_hash[:section] = section
      results_hash[:content] = content

      results_array << results_hash
    end

    results_array
  end

  private

  def self.get_published_version(active_publication, content)
    content_version = nil
    published_website_id = active_publication.id
    published_element = PublishedElement.includes([:published_website])
                                        .where('published_websites.id = ?', published_website_id)
                                        .where('published_element_record_id = ?', content.id)
                                        .where('published_element_record_type = ?', 'Content').first

    unless published_element.nil?
      content_version = Content::Version.where('version = ? and content_id = ?', published_element.version, published_element.published_element_record_id).first
    end
    content_version
  end
end
