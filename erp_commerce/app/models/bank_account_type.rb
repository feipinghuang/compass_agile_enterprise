### Table Definition ###############################
#  create_table :bank_account_types do |t|
#    t.string :description
#    t.string :internal_identifier
#
#    t.timestamps
#  end
####################################################

class BankAccountType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many :bank_accounts

  def self.iid(internal_identifier)
    self.where(internal_identifier: internal_identifier).first
  end

  def self.find_or_create(internal_identifier, description)
    if self.iid(internal_identifier)
      self.iid(internal_identifier)
    else
      self.create(internal_identifier: internal_identifier, description: description)
    end
  end
  
end
