Party.class_eval do
  has_many :resource_availabilities, :class_name => 'PartyResourceAvailability', :dependent => :destroy
  has_many :party_skills
  has_many :position_fulfillments, foreign_key: "held_by_party_id"
  has_many :experiences
  has_many :wc_codes, dependent: :destroy
  has_many :shifts, dependent: :destroy
  has_many :resumes

  #
  # scoping helpers
  #

  class << self
    # scope by project
    #
    # @param project [Integer | Project | Array] either a id of Project record, a Project record, an array of Project records
    # or an array of Project ids
    # @param options [Hash] options to apply to this scope
    # @option options [Array] :role_types role types to include in the scope
    #
    # @return [ActiveRecord::Relation]
    def scope_by_project(project, options={})
      statement = joins("join entity_party_roles project_epr on project_epr.party_id = parties.id")
                      .where('project_epr.entity_record_type = ?', 'Project')
                      .where('project_epr.entity_record_id' => project)

      if options[:role_types]
        statement = statement.joins("join role_types project_rt on project_rt.id = project_epr.role_type_id")
                        .where('project_rt.id' => RoleType.find_child_role_types(options[:role_types]))
      end

      statement
    end
  end

  #
  # end scoping helpers
  #

  #
  # relationship helpers
  #

  # create relationship between a party and a project
  #
  # @param project [Project] project to relate this party to
  # @param options [Hash] options to apply to this scope
  # @option options [Array] :role_types role types to use in the relationship
  #
  # @return [Party] self
  def create_project_relationship(project, options)
    # make sure role_types is passed
    raise StandardError('Party to Project relationships require a role_types option') if options[:role_types].blank?

    options[:role_types].each do |role_type|

      current_relationship = EntityPartyRole.where("entity_record_type = 'Project' and entity_record_id = ?
                                                    and party_id = ? and role_type_id = ?",
                                                   project.id,
                                                   self.id,
                                                   role_type.id).first
      unless current_relationship
        EntityPartyRole.create(
            entity_record: project,
            party: self,
            role_type: role_type
        )
      end
    end

    self
  end

  # destroy relationship between a party and a project
  #
  # @param project [Project] project to remove the relationship with
  # @param options [Hash] options to apply to this scope
  # @option options [Array] :role_types role types to remove in this relationship. Pass no role_types option
  # to remove all relationships regardless of role_types
  #
  # @return [Party] self
  def destroy_project_relationship(project, options)
    if options[:role_types]
      options[:role_types].each do |role_type|

        relationship = EntityPartyRole.where("entity_record_type = 'Project' and entity_record_id = ?
                                              and party_id = ? and role_type_id = ?",
                                             project.id,
                                             self.id,
                                             role_type.id).first
        if relationship
          relationship.destroy
        end
      end

    else
      entity_party_roles.delete_all(entity_record_type: 'Project', entity_record_id: project.id)
    end

    self
  end

  # updates a relationship between a party and a project.  By using this method you are implying there should be only
  # one relationship with the given role type between a party and a project.  Any other relationships will be
  # destroyed.  If no current relationship is found it will create a new one.
  #
  # @param project [Project] project to update the relationship with
  # @param options [Hash] options to apply to this scope
  # @option options [Array] :role_types role types to update in this relationship.
  #
  # @return [Party] self
  def update_project_relationship(project, options)
    # make sure role_types is passed
    raise StandardError('Party to Project relationships require a role_types option') if options[:role_types].blank?

    if options[:role_types]
      options[:role_types].each do |role_type|

        relationship = EntityPartyRole.where("entity_record_type = 'Project'
                                              and party_id = ? and role_type_id = ?",
                                             self.id,
                                             role_type.id).first
        if relationship
          relationship.project = project
          relationship.save!
        else
          create_project_relationship(project, options)
        end
      end

    else
      entity_party_roles.delete_all(entity_record_type: 'Project', entity_record_id: project.id)
    end

    self
  end

  #
  # end relationship helpers
  #

end
