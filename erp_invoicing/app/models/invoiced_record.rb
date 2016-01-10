class InvoicedRecord < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :invoice_item
  belongs_to :invoiceable_item, :polymorphic => true

  # Weather or not this item is taxed
  #
  def taxed?
    if invoiceable_item.respond_to?(:taxed?)
      invoiceable_item.taxed?
    elsif invoiceable_item.respond_to?(:taxable?)
      invoiceable_item.taxable?
    else
      false
    end
  end

end