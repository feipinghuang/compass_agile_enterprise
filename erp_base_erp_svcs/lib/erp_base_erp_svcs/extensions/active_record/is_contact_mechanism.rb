module ErpBaseErpSvcs
  module Extensions
    module ActiveRecord
      module IsContactMechanism
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def is_contact_mechanism
            extend IsContactMechanism::SingletonMethods
            include IsContactMechanism::InstanceMethods

            after_initialize :initialize_contact
            after_create :save_contact
            after_update :save_contact
            after_destroy :destroy_contact

            has_one :contact, :as => :contact_mechanism, :dependent => :destroy

            [:purpose,
             :purposes,
             :is_primary,
             :is_primary=,
             :is_primary?].each { |m| delegate m, :to => :contact }
          end
        end

        module SingletonMethods
          # return all contact mechanism instances for parties
          def for_parties(parties, contact_purposes=[])
            contact_purpose_ids = if contact_purposes.blank?
                                    ContactPurpose.pluck(:id).join(',')
                                  elsif contact_purposes.is_a?(ContactPurpose)
                                    contact_purposes.id
                                  else
                                    contact_purposes.map(&:id).join(',')
                                  end
            self.joins("inner join contacts on phones.id=contacts.contact_mechanism_id inner join parties on parties.id=contacts.contact_record_id inner join contact_purposes_contacts on contact_purposes_contacts.contact_id=contacts.id and contact_purposes_contacts.contact_purpose_id in (#{contact_purpose_ids})").where("parties.id in(#{parties.map(&:id).join(',')})")

          end
        end

        module InstanceMethods

          def save_contact
            self.contact.save
          end

          # return all contact purposes in one comma separated string
          def contact_purposes_to_s
            contact.contact_purposes.collect(&:description).join(', ')
          end

          def add_contact_purpose(contact_purpose)
            unless contact_purpose.is_a?(ContactPurpose)
              contact_purpose = ContactPurpose.iid(contact_purpose)
            end

            # don't add the contact purpose if its already there
            unless contact_purpose_iids.include?(contact_purpose.internal_identifier)
              contact.contact_purposes << contact_purpose
              contact.save
            end
          end

          # return all contact purpose iids in one comma separated string
          def contact_purpose_iids
            contact.contact_purposes.collect(&:internal_identifier).join(',')
          end

          # return all contact purposes
          def contact_purposes
            contact.contact_purposes
          end

          def destroy_contact
            self.contact.destroy unless self.contact.nil?
          end

          def initialize_contact
            if self.new_record? || self.contact.nil?
              self.contact = Contact.new
              self.contact.description = self.description
            end
          end

        end

      end #HasContact
    end #ActiveRecord
  end #Extensions
end #ErpBaseErpSvcs
