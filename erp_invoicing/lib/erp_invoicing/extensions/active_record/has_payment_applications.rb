module ErpInvoicing
  module Extensions
    module ActiveRecord
      module HasPaymentApplications
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def has_payment_applications
            extend HasPaymentApplications::SingletonMethods
            include HasPaymentApplications::InstanceMethods

            has_many :payment_applications, :as => :payment_applied_to, :dependent => :destroy do
              def pending
                all.select{|item| item.is_pending?}
              end

              def successful
                all.select{|item| item.financial_txn.has_captured_payment?}
              end
            end

          end

        end

        module SingletonMethods
        end

        module InstanceMethods

          def get_payment_applications(status=:all)
            case status.to_sym
              when :pending
                payment_applications.pending
              when :successful
                payment_applications.successful
              when :all
                payment_applications
            end
          end

          def has_payments?(status=:all)
            selected_payment_applications = self.get_payment_applications(status)
            !(selected_payment_applications.nil? or selected_payment_applications.empty?)
          end

          def total_payments
            self.get_payment_applications(:successful).sum { |item| item.money.amount }
          end

          def total_pending_payments
            self.payment_applications.pending.sum{|item| item.money.amount}
          end

        end

      end #End HasPaymentApplications module
    end #End ActiveRecord module
  end #End Extensions module
end #End ErpInvoicing module