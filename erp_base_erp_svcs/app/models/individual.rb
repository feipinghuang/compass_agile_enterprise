class Individual < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  after_create :create_party
  after_save :save_party
  after_destroy :destroy_party

  has_one :party, :as => :business_party

  attr_encrypted :ssn, :key => Rails.application.config.erp_base_erp_svcs.encryption_key, :attribute => :encrypted_ssn

  def after_initialize
    self.salt ||= Digest::SHA256.hexdigest((Time.now.to_i * rand(5)).to_s)
  end

  alias :social_security_number= :ssn=
  alias :social_security_number :ssn

  def formatted_ssn_label
    (self.ssn_last_four.blank?) ? "" : "XXX-XX-#{self.ssn_last_four}"
  end

  def self.from_registered_user(a_user)
    ind = Individual.new
    ind.current_first_name = a_user.first_name
    ind.current_last_name = a_user.last_name

    #this is necessary because this is where the callback creates the party instance.
    ind.save

    a_user.party = ind.party
    a_user.save
    ind.save
    #this is necessary because save returns a boolean, not the saved object
    return ind
  end

  def create_party
    unless self.party
      pty = Party.new
      pty.description = [current_personal_title, current_first_name, current_last_name].join(' ').strip
      pty.business_party = self
      pty.save
      self.party = pty
      self.save
    end
  end

  def save_party
    if self.party.description.blank? && (!current_first_name.blank? && !current_last_name.blank?)
      self.party.description = [current_personal_title, current_first_name, current_last_name].join(' ').strip
      self.party.save
    end
  end

  def destroy_party
    if self.party
      self.party.destroy
    end
  end

  def to_label
    "#{current_first_name} #{current_last_name}"
  end
end
