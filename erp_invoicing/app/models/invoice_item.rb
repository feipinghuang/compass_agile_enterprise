#### Table Definition ###########################
#  create_table :invoice_items do |t|
#    #foreign keys
#    t.references :invoice
#    t.references :invoice_item_type
#
#    #non-key columns
#    t.integer    :item_seq_id
#    t.string     :item_description
#    t.decimal    :unit_price, :precision => 8, :scale => 2
#    t.boolean    :taxable
#    t.decimal    :sales_tax, :precision => 8, :scale => 2
#    t.decimal    :quantity, :precision => 8, :scale => 2
#    t.decimal    :amount, :precision => 8, :scale => 2
#
#    t.timestamps
#  end

#  add_index :invoice_items, :invoice_id, :name => 'invoice_id_idx'
#  add_index :invoice_items, :invoice_item_type_id, :name => 'invoice_item_type_id_idx'
#################################################

class InvoiceItem < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :invoice
  belongs_to :agreement
  belongs_to :invoice_item_type

  has_many :invoiced_records, :dependent => :destroy
  has_many :sales_tax_lines, as: :taxed_record, dependent: :destroy

  has_payment_applications

  def taxable?
    self.taxable
  end

  def total_amount
    if taxable?
      (sub_total + self.sales_tax).round(2)
    else
      sub_total
    end
  end

  def sub_total
    _amount = self.amount

    if _amount.blank?
      _amount = (self.unit_price * self.quantity)
    end

    _amount.round(2)
  end

  def balance
    (self.total_amount - self.total_payments).round(2)
  end

  # calculates tax and save to sales_tax
  def calculate_tax(ctx={})
    taxation = ErpOrders::Taxation.new

    tax = taxation.calculate_tax(self,
                                 ctx.merge({
                                               amount: (self.unit_price * (self.quantity || 1))
                                           }))

    self.sales_tax = tax
    self.save

    tax
  end

  def add_invoiced_record(record)
    invoiced_records << InvoicedRecord.new(invoiceable_item: record)
  end

  def to_s
    item_description
  end

  def product_descriptions
    # return an array of product descriptions for this invoice item
    descriptions = []
    invoiced_records.each do |invoiced_record|
      descriptions << invoiced_record.invoiceable_item.description
    end
    if descriptions.count == 0
      descriptions << "No Product Description"
    end
    descriptions
  end

  def to_label
    to_s
  end

end
