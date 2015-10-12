::Party.class_eval do

  def applications
    Application.joins("inner join entity_party_roles on entity_party_roles.entity_record_type = 'Application'
                       and entity_party_roles.entity_record_id = applications.id")
               .where('entity_party_roles.party_id = ?', self.id)
  end

end
