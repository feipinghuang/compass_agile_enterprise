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
          #
          # @param party [Party] Party to get contacts for
          # @param contact_purposes [Array] Array of ContactPurposes to look up
          def for_party(party, contact_purposes=[])
            for_parties([party], contact_purposes)
          end

          # return all contact mechanism instances for parties
          #
          # @param parties [Array] Array of parties to get contacts for
          # @param contact_purposes [Array] Array of ContactPurposes to look up
          def for_parties(parties, contact_purposes=[])
            query = self.joins(contact: [:contact_purposes])

            unless contact_purposes.empty?
              query = query.where(contact_purposes: {id: contact_purposes})
            end

            query.where(contacts: {contact_record_type: 'Party', contact_record_id: parties})
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
            if self.new_record? and self.contact.nil?
              self.contact = Contact.new
              self.contact.description = self.description
            end
          end

        end

      end #HasContact
    end #ActiveRecord
  end #Extensions
end #ErpBaseErpSvcs
