# create_table :capabilities do |t|
#   t.string :description
#   t.references :capability_type
#   t.references :capability_resource, :polymorphic => true
#   t.integer :scope_type_id
#   t.text :scope_query
#   t.timestamps
# end
#
# add_index :capabilities, :capability_type_id
# add_index :capabilities, :scope_type_id
# add_index :capabilities, [:capability_resource_id, :capability_resource_type], :name => 'capability_resource_index'

class Capability < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :scope_type
  belongs_to :capability_type
  belongs_to :capability_resource, :polymorphic => true
  has_many :capability_accessors, :dependent => :destroy

  alias :type :capability_type

  after_create :update_description

  def update_description
    if description.blank?
      desc = "#{capability_type.description} #{capability_resource_type}"
      case scope_type
      when ScopeType.find_by_internal_identifier('class')
        self.description = "#{desc}"
      when ScopeType.find_by_internal_identifier('instance')
        self.description = "#{desc} #{capability_resource.to_s} Instance"
      when ScopeType.find_by_internal_identifier('query')
        self.description = "#{desc} Scope"
      end
      self.save
    end
  end

  def roles_not
    SecurityRole.joins("LEFT JOIN capability_accessors ON capability_accessors.capability_id = #{self.id}
                        AND capability_accessors.capability_accessor_record_type = 'SecurityRole' 
                        AND capability_accessors.capability_accessor_record_id = security_roles.id").
      where("capability_accessors.id IS NULL")
  end

  def remove_all_roles
    capability_accessors.destroy_all
  end

  def roles
    SecurityRole.joins(:capability_accessors).where(:capability_accessors => {:capability_id => self.id })
  end

  def users_not
    User.joins("LEFT JOIN capability_accessors ON capability_accessors.capability_id = #{self.id}
                        AND capability_accessors.capability_accessor_record_type = 'User' 
                        AND capability_accessors.capability_accessor_record_id = users.id").
      where("capability_accessors.id IS NULL")
  end

  def users
    User.joins(:capability_accessors).where(:capability_accessors => {:capability_id => self.id })
  end

  def groups_not
    Group.joins("LEFT JOIN capability_accessors ON capability_accessors.capability_id = #{self.id}
                        AND capability_accessors.capability_accessor_record_type = 'Group' 
                        AND capability_accessors.capability_accessor_record_id = groups.id").
      where("capability_accessors.id IS NULL")
  end

  def groups
    Group.joins(:capability_accessors).where(:capability_accessors => {:capability_id => self.id })
  end

  def to_data_hash
    to_hash(only: [:id, :description])
  end
end
