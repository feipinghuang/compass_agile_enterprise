# create_table :published_websites do |t|
#   t.references :website
#   t.text :comment
#   t.decimal :version, :precision => 18, :scale => 6
#   t.boolean :active
#   t.integer :published_by_id
#
#   t.timestamps
# end
#
# #indexes
# add_index :published_websites, :website_id
# add_index :published_websites, :version
# add_index :published_websites, :active
# add_index :published_websites, :published_by_id

class PublishedWebsite < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :website
  belongs_to :published_by, :class_name => "User"
  has_many :published_elements, :dependent => :delete_all

  def published_by_username
    self.published_by.username rescue ''
  end

  def self.activate(website, version, current_user)
    #deactivate
    published_websites = self.where(:website_id => website.id).where(:active => true).all
    published_websites.each do |published_website|
      published_website.active = false
      published_website.save
    end

    #activate
    published_website = self.where(:website_id => website.id).where(:version => version).first
    published_website.active = true
    published_website.published_by = current_user
    published_website.save
  end

  def publish(comment, current_user)
    # if the site is currently being published we need to wait
    # we want to sleep for 2 seconds and only try 3 times then give up
    try_count = 0
    while website.reload.publishing? and try_count < 2
      sleep(2.seconds)
      try_count += 1
    end

    # lock website for publishing
    website.publishing = true
    website.save

    # wrap in transaction so if something fails it rolls back
    ActiveRecord::Base.transaction do
      new_publication = clone_publication(comment, current_user)
      elements = []

      #get a publish sections
      website_sections = new_publication.website.website_sections
      website_sections = website_sections | website_sections.collect { |section| section.descendants }.flatten
      website_sections.each do |website_section|
        #get nested elements too
        website_section.self_and_descendants.each do |website_section|
          if new_publication.published_elements.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', website_section.id, website_section.class.to_s, website_section.class.superclass.to_s).first.nil?
            published_element = PublishedElement.new
            published_element.published_website = new_publication
            published_element.published_element_record = website_section
            published_element.version = website_section.version
            published_element.published_by = current_user
            published_element.save
          end
        end

        if website_section.is_a?(OnlineDocumentSection)
          elements = elements | [website_section.documented_item.content]
        else
          elements = elements | website_section.contents
        end
      end

      #make sure all elements have published_element objects
      elements.each do |element|
        if new_publication.published_elements.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', element.id, element.class.to_s, element.class.superclass.to_s).first.nil?
          published_element = PublishedElement.new
          published_element.published_website = new_publication
          published_element.published_element_record = element
          published_element.version = element.version
          published_element.published_by = current_user
          published_element.save
        end
      end

      #get latest version for all elements
      new_publication.published_elements.each do |published_element|
        published_element.version = published_element.published_element_record.version
        published_element.save
      end

      #check if we want to auto active this publication
      if new_publication.website.auto_activate_publication?
        PublishedWebsite.activate(new_publication.website, new_publication.version, current_user)
      end

    end

    # unlock website for publishing
    website.publishing = false
    website.save
  end

  def publish_element(comment, element, version, current_user)
    # if the site is currently being published we need to wait
    # we want to sleep for 2 seconds and only try 3 times then give up
    try_count = 0
    while website.reload.publishing? and try_count < 2
      sleep(2.seconds)
      try_count += 1
    end

    # lock website for publishing
    website.publishing = true
    website.save

    # wrap in transaction so if something fails it rolls back
    ActiveRecord::Base.transaction do
      new_publication = clone_publication(comment, current_user)

      published_element = new_publication.published_elements.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', element.id, element.class.to_s, element.class.superclass.to_s).first

      unless published_element.nil?
        published_element.version = version
        published_element.published_by = current_user
        published_element.save
      else
        new_published_element = PublishedElement.new
        new_published_element.published_website = new_publication
        new_published_element.published_element_record = element
        new_published_element.version = version
        new_published_element.published_by = current_user
        new_published_element.save
      end

      #check if we want to auto active this publication
      if new_publication.website.auto_activate_publication?
        PublishedWebsite.activate(new_publication.website, new_publication.version, current_user)
      end
    end

    # unlock website for publishing
    website.publishing = false
    website.save
  end

  private

  def clone_publication(comment, current_user)
    #create new PublishedWebsite with comment
    published_website = PublishedWebsite.new
    published_website.website = self.website

    published_website.version = (self.version.to_i + 1)

    published_website.published_by = current_user
    published_website.comment = comment
    published_website.save

    #create new PublishedWebsiteElements
    published_elements.each do |published_element|
      new_published_element = PublishedElement.new
      new_published_element.published_website = published_website
      new_published_element.published_element_record = published_element.published_element_record
      new_published_element.version = published_element.version
      new_published_element.published_by = current_user
      new_published_element.save
    end

    published_website
  end
end