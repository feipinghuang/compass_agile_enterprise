FinancialTxn.class_eval do
  has_many :payments

  def has_captured_payment?
    has_payments? and self.payments.last.current_state == 'captured'
  end

  def has_authorized_payment?
    has_payments? and self.payments.last.current_state == 'authorized'
  end

  def has_pending_payment?
    has_payments? and self.payments.last.current_state == 'pending'
  end

  def is_pending?
    self.is_scheduled? || self.has_pending_payment?
  end

  def is_scheduled?
    ((self.apply_date > Date.today) or (!self.has_payments?))
  end

  def has_payments?
    !self.payments.empty?
  end

  def most_recent_payment
    Payment.order('created_at DESC').where('financial_txn_id = ?', self.id).first
  end

  def capture(gateway_wrapper, gateway_options={})
    begin
      ActiveRecord::Base.transaction do
        # make sure we have payments and they are authorized
        if has_authorized_payment?
          result = {success: true}

          if txn_type.internal_identifier == 'credit_card_payment'
            result = CreditCardAccount.new.capture(self, gateway_wrapper, gateway_options)

          else
            payment = most_recent_payment
            payment.capture
            payment.save

            result[:message] = 'Payment Captured'
          end

          # if the capture was a success apply the payments
          if result[:success]
            payment_applications.each do |payment_application|
              payment_application.apply_payment
            end
          end

          result

        end
      end
    rescue => ex
      Rails.logger.error(ex.message)
      Rails.logger.error(ex.backtrace.join("\n"))

      {success: false, message: 'Could not refund'}
    end
  end

  def refund(gateway_wrapper, gateway_options={})
    begin
      ActiveRecord::Base.transaction do
        # make sure we have payments and they are captured
        if has_captured_payment?
          result = {success: true}

          if txn_type.internal_identifier == 'credit_card_payment'
            result = CreditCardAccount.new.refund(self, gateway_wrapper, gateway_options)

          else
            payment = most_recent_payment
            payment.refund
            payment.save

            result[:message] = 'Payment Refunded'
          end

          # if the refund was a success un-apply the payments
          if result[:success]
            payment_applications.each do |payment_application|
              payment_application.unapply_payment
            end
          end

          result

        end
      end
    rescue => ex
      Rails.logger.error(ex.message)
      Rails.logger.error(ex.backtrace.join("\n"))

      {success: false, message: 'Could not refund'}
    end
  end

end