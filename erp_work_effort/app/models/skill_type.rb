class SkillType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  has_many  :party_skills
  has_many  :parties, :through => :party_skills

  class << self
	  def iid(internal_identifier)
	    find_by_internal_identifier(internal_identifier)
	  end
	end
end
