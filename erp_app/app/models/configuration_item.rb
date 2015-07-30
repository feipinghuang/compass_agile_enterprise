class ConfigurationItem < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :configuration
  belongs_to :configuration_item_type

  has_and_belongs_to_many :configuration_options
  before_destroy :clear_configuration_options

  def clear_configuration_options
    configuration_options.clear
  end

  alias :config :configuration
  alias :options :configuration_options
  alias :type :configuration_item_type

  def category
    self.type.category
  end

  def to_js_hash
    {:id => self.id,
      :configruationItemType => self.type.to_js_hash,
      :configurationOptions => options.collect(&:to_js_hash)
    }
  end

  def clear_options
    self.options.each{|option|option.destroy} if self.configuration_item_type.allow_user_defined_options?
    self.options.destroy_all
    self.save
  end

  def value
    if options.count == 1
      options.first.value
    else
      options
    end
  end

  def set_options(internal_identifiers_or_value)
    if self.configuration_item_type.allow_user_defined_options?
      value = internal_identifiers_or_value.first
      unless value.blank?
        self.options << ConfigurationOption.create(:value => value, :user_defined => true)
      end
    elsif self.configuration_item_type.is_multi_optional?
      internal_identifiers_or_value.each do |value|
        self.options << self.configuration_item_type.find_configuration_option(value) unless value.blank?
      end
    else
      value = internal_identifiers_or_value.first
      self.options << self.configuration_item_type.find_configuration_option(internal_identifiers_or_value) unless value.blank?
    end

    self.save
  end
end
