module ErpTxnsAndAccts
  module Extensions
    module ActiveRecord
      module ActsAsBizTxnEvent

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_biz_txn_event
            extend ActsAsBizTxnEvent::SingletonMethods
            include ActsAsBizTxnEvent::InstanceMethods

            after_initialize :initialize_biz_txn_event
            after_create :save_biz_txn_event
            after_update :save_biz_txn_event
            after_destroy :destroy_biz_txn_event

            has_one :biz_txn_event, :as => :biz_txn_record
            belongs_to :biz_txn_acct_root

            #from BizTxnEvent
            [:txn_type, :txn_type=,
             :txn_type_iid, :txn_type_iid=,
             :biz_txn_type_id, :biz_txn_type_id=,
             :external_id_source, :external_id_source=,
             :external_identifier, :external_identifier=,
             :description, :description=,
             :post_date, :post_date=,
             :created_at, :created_at=,
             :updated_at, :updated_at=,
             :create_dependent_txns, :account,
             :add_party_with_role, :find_party_by_role,
             #
             # has_tracked_status delegations
             #
             :has_status?, :had_status?, :has_had_status?, :get_status_for_date_time,
             :get_statuses_for_date_time_range, :current_status_application, :current_status_type,
             :current_status, :current_status=, :previous_status, :add_status
            ].each { |m| delegate m, :to => :biz_txn_event }
          end
        end

        module SingletonMethods
          def with_current_status(status)
            self.joins(:biz_txn_event).where("biz_txn_events.id in (#{BizTxnEvent.select('biz_txn_events.id').with_current_status(status).to_sql})")
          end

          def without_current_status(status)
            self.joins(:biz_txn_event).where("biz_txn_events.id in (#{BizTxnEvent.select('biz_txn_events.id').without_current_status(status).to_sql})")
          end

          def join_root_txn
            joins(:biz_txn_event).uniq
          end

        end

        module InstanceMethods
          def root_txn
            self.biz_txn_event
          end

          #allow for a client to pass either an account root or a polymorphic subclass of
          #account root, but always set the account to the root
          def account=(acct)
            if acct.instance_of?(BizTxnAcctRoot)
              self.biz_txn_event.biz_txn_acct_root = (acct)
            else
              self.biz_txn_event.biz_txn_acct_root = (acct.biz_txn_acct_root)
            end
          end

          def save_biz_txn_event
            self.biz_txn_event.save
          end

          def initialize_biz_txn_event
            if self.new_record? and self.biz_txn_event.nil?
              t = BizTxnEvent.new
              self.biz_txn_event = t
              t.biz_txn_record = self
            end
          end

          def destroy_biz_txn_event
            self.biz_txn_event.destroy if (self.biz_txn_event && !self.biz_txn_event.frozen?)
          end
        end

      end
    end
  end
end