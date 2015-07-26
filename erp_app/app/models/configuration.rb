class Configuration < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  scope :templates, where('is_template = ?', true)

  validates :internal_identifier, :presence => true, :uniqueness => {:scope => [:id, :is_template]}

  validate :cannot_have_two_templates_per_iid

  before_destroy :clear_configuration_item_types

  def cannot_have_two_templates_per_iid
    if self.is_template
      unless Configuration.where('id != ?', self.id).where(:is_template => true).where(:internal_identifier => self.internal_identifier).first.nil?
        errors.add(:is_template, "Cannot have more than one template per configuration")
      end
    end
  end

  has_many :configuration_items, :dependent => :destroy do
    def by_category(category)
      joins({:configuration_item_type => [:category_classification]}).where(:category_classifications => {:category_id => category})
    end

    def grouped_by_category
      group_by(&:category)
    end
  end

  has_and_belongs_to_many :configuration_item_types, :uniq => true do
    def by_category(category)
      joins(:category_classification).where(:category_classifications => {:category_id => category})
    end

    def grouped_by_category
      group_by(&:category)
    end
  end

  def clear_configuration_item_types
    configuration_item_types.clear
  end

  alias :items :configuration_items
  alias :item_types :configuration_item_types

  def is_template?
    self.is_template
  end

  def add_configuration_item(configuration_item_type, *option_internal_identifiers)
    option_internal_identifiers = option_internal_identifiers.collect { |item| item.to_s }
    configuration_item_type = (configuration_item_type.is_a? ConfigurationItemType) ? configuration_item_type : ConfigurationItemType.find_by_internal_identifier(configuration_item_type.to_s)

    item = get_configuration_item(configuration_item_type)
    if item
      update_configuration_item(configuration_item_type, option_internal_identifiers)
    else
      unless self.configuration_item_types.where("id = ?", configuration_item_type.id).first.nil?
        item = ConfigurationItem.create(:configuration_item_type => configuration_item_type)
        item.set_options(option_internal_identifiers)
        self.configuration_items << item
        self.save
      else
        raise "Configuration Item Type #{configuration_item_type.description} is not valid for this configuration"
      end
    end
  end

  alias :add_item :add_configuration_item

  def update_configuration_item(configuration_item_type, *option_internal_identifiers)
    configuration_item_type = (configuration_item_type.is_a? ConfigurationItemType) ? configuration_item_type : ConfigurationItemType.find_by_internal_identifier(configuration_item_type.to_s)

    item = self.items.where('configuration_item_type_id = ?', configuration_item_type.id).first
    raise "Configuration item #{configuration_item_type.description} does not exist for configuration #{self.description}" if item.nil?

    item.clear_options
    item.set_options(option_internal_identifiers.flatten)
  end

  alias :update_item :update_configuration_item

  def get_configuration_item(configuration_item_type)
    configuration_item_type = (configuration_item_type.is_a? ConfigurationItemType) ? configuration_item_type : ConfigurationItemType.find_by_internal_identifier(configuration_item_type.to_s)

    self.items.where('configuration_item_type_id = ?', configuration_item_type.id).first
  end

  alias :get_item :get_configuration_item

  # Clone
  #
  # Will copy all configuration item types
  #
  # * *Args*
  #   - +set_defaults+ -> create items and set default options default = true
  #   - +description+ -> description to set = nil
  #   - +internal_identifier+ -> internal_identifier to set = nil
  # * *Returns* :
  #   - the cloned configuration
  def clone(set_defaults=true, description=nil, internal_identifier=nil)
    configuration_dup = self.dup
    configuration_dup.internal_identifier = internal_identifier || self.internal_identifier
    configuration_dup.description = description || self.description
    configuration_dup.is_template = false

    self.configuration_item_types.each do |configuration_item_type|
      configuration_dup.configuration_item_types << configuration_item_type
    end
    configuration_dup.save

    configuration_dup.configuration_item_types.each do |configuration_item_type|
      configuration_item = ConfigurationItem.create(:configuration_item_type => configuration_item_type)
      configuration_item.configuration_options = configuration_item_type.options.default if set_defaults
      configuration_item.save
      configuration_dup.configuration_items << configuration_item
    end
    configuration_dup.save

    configuration_dup
  end

  # Copy
  #
  # Will copy all configuration item types and items
  #
  # * *Args*
  #   - +description+ -> description to set = nil
  #   - +internal_identifier+ -> internal_identifier to set = nil
  # * *Returns* :
  #   - the copied configuration
  def copy(description=nil, internal_identifier=nil)
    configuration_dup = self.dup
    configuration_dup.internal_identifier = internal_identifier || self.internal_identifier
    configuration_dup.description = description || self.description
    configuration_dup.is_template = false

    self.configuration_item_types.each do |configuration_item_type|
      configuration_dup.configuration_item_types << configuration_item_type
    end
    configuration_dup.save

    #clone items
    self.configuration_items.each do |item|
      item_dup = item.dup

      # remove old configuration id
      item_dup.configuration_id = nil

      item_dup.configuration_item_type = item.configuration_item_type
      item.configuration_options.each do |option|
        if option.user_defined
          item_dup.configuration_options << option.dup
        else
          item_dup.configuration_options << option
        end

      end
      configuration_dup.configuration_items << item_dup
    end

    configuration_dup.save
    configuration_dup
  end

  class << self
    def find_template(iid)
      self.templates.where('internal_identifier = ?', iid).first
    end
  end

end
