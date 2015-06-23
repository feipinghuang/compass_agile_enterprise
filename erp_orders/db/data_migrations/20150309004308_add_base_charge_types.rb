class AddBaseChargeTypes

  def self.up
    ActiveRecord::Base.transaction do
      ChargeType.create(description: 'Shipping', internal_dentifier: 'shipping', taxable: true)
      ChargeType.create(description: 'Tax', internal_dentifier: 'tax', taxable: true)
      ChargeType.create(description: 'Assembly', internal_dentifier: 'assembly', taxable: true)
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      ChargeType.find_by_internal_identifier('shipping').destroy
      ChargeType.find_by_internal_identifier('tax').destroy
      ChargeType.find_by_internal_identifier('assembly').destroy
    end
  end

end
