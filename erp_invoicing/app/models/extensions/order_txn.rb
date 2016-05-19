OrderTxn.class_eval do

  def has_generated_invoice?
    (Invoice.items_generated_by(self).count != 0)
  end

  def generated_invoice
    Invoice.items_generated_by(self).first
  end

  def has_payments?(status=:all)
    (has_generated_invoice? && Invoice.items_generated_by(self).first.has_payments?(status))
  end

end