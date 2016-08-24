class InvoiceType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  def self.iid(internal_identifier)
  	where(internal_identifier: internal_identifier).first
  end
end
