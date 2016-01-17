class AddInvoiceTrackedStatuses

  def self.up
    invoice_statuses = TrackedStatusType.find_or_create('invoice_statuses', 'Invoice Statuses')

    TrackedStatusType.find_or_create('invoice_statuses_open', 'Open', invoice_statuses)
    TrackedStatusType.find_or_create('invoice_statuses_hold', 'Hold', invoice_statuses)
    TrackedStatusType.find_or_create('invoice_statuses_sent', 'Sent', invoice_statuses)
    TrackedStatusType.find_or_create('invoice_statuses_closed', 'Closed', invoice_statuses)
  end

  def self.down
    status = TrackedStatusType.where(internal_identifier: 'invoice_statuses').first
    if status
      status.destroy
    end
  end

end
