class DocumentedContent < Content
  attr_protected :created_at, :updated_at

  before_save :check_internal_identifier

  def to_param
    permalink
  end

  def check_internal_identifier
    self.internal_identifier = self.permalink if self.internal_identifier.blank?
  end

  def content_hash
    {:id => self.id, :title => self.title, :body_html => self.body_html}
  end

  def self.find_published_by_section(active_publication, website_section)
    published_content = []
    documented_item = DocumentedItem.where(["online_document_section_id = ?", website_section.id]).first
    if documented_item
      documented_content = DocumentedContent.find(documented_item.documented_content_id)
      content = get_published_version(active_publication, documented_content)
      published_content << content unless content.nil?
    end

    published_content.first
  end

  def self.search(options = {})
    predicate = self.joins('inner join documented_items on documented_items.documented_content_id = contents.id')
    .joins('inner join website_sections on website_sections.id = documented_items.online_document_section_id')

    if options[:section_unique_name]
      predicate = predicate.where("website_sections.internal_identifier = ?", options[:section_unique_name])
    end

    if options[:parent_id]
      predicate = predicate.where("website_sections.id" => WebsiteSection.find(options[:parent_id]).descendants.collect(&:id))
    end

    if options[:content_type]
      predicate = predicate.where("website_sections.type = ?", options[:content_type])
    end

    if options[:website_id]
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

  def self.build_search_results(results)
    # and if it is a blog get the article link and title
    results_array = []
    results.each do |content|
      section = DocumentedItem.find_by_documented_content_id(content.id).online_document_section

      results_hash = {}
      results_hash[:internal_identifier] = section.internal_identifier
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

end
