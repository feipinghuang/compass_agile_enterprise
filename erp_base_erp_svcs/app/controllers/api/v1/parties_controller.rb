module Api
  module V1
    class PartiesController < BaseController

      def index
        query = params[:query]
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'description'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0
        role_types = params[:role_types]

        parties = Party

        unless query.blank?
          parties_tbl = Party.arel_table

          where_clause = nil
          # if the query has commas split on the commas and treat them as separate search terms
          query.split(',').each do |query_part|
            if where_clause.nil?
              where_clause = parties_tbl[:description].matches(query_part.strip + '%')
            else
              where_clause = where_clause.or(parties_tbl[:description].matches(query_part.strip + '%'))
            end
          end

          parties = parties.where(where_clause)
        end

        unless params[:id].blank?
          parties = parties.where(id: params[:id].split(','))
        end

        unless role_types.blank?
          if params[:include_child_roles]
            role_types = RoleType.find_child_role_types(role_types.split(',')).collect{|role_type| role_type.internal_identifier}
          else
            role_types = role_types.split(',')
          end

          parties = parties.joins(party_roles: :role_type).where('role_types.internal_identifier' => role_types)
        end

        # scope by dba organization
        if params[:include_descendants].present? and params[:include_descendants].to_bool
          dba_organization = [current_user.party.dba_organization]
          dba_organization.concat(current_user.party.dba_organization.child_dba_organizations)

          parties = parties.scope_by_dba_organization(dba_organization)
        else
          parties = parties.scope_by_dba_organization(current_user.party.dba_organization)
        end

        parties = parties.uniq.order("#{sort} #{dir}")

        total_count = parties.count
        parties = parties.offset(start).limit(limit)

        render :json => {total_count: total_count, parties: parties.collect(&:to_data_hash)}
      end

      def create
        begin
          ActiveRecord::Base.transaction do
            role_type_iids = params[:role_types].present? ? params[:role_types].split(',') : []
            business_party_klass = params[:business_party]

            business_party = business_party_klass.constantize.new
            if business_party_klass == 'Organization'
              business_party.description = params[:description].strip
            else
              business_party.current_first_name = params[:first_name].strip
              business_party.current_last_name = params[:last_name].strip
            end

            business_party.save!

            dba_organization = current_user.party.dba_organization
            role_type_iids.each do |role_type_iid|
              role_type = RoleType.iid(role_type_iid)

              PartyRole.create(party: business_party.party, role_type: role_type)

              # associate to dba_org
              relationship_type = RelationshipType.find_or_create(RoleType.iid('dba_org'), role_type)

              business_party.party.create_relationship(relationship_type.description,
                                                       dba_organization.id,
                                                       relationship_type)
            end

            business_party.party.created_by_party = current_user.party
            business_party.party.save!

            render :json => {success: true, party: business_party.party.to_data_hash}
          end
        rescue ActiveRecord::RecordInvalid => invalid

          render :json => {success: false, message: invalid.record.errors.messages}
        rescue => ex
          Rails.logger.error ex.message
          Rails.logger.error ex.backtrace.join("\n")

          # email error
          ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

          render :json => {success: false, message: 'Application Error'}
        end
      end

      def show
        party = Party.find(params[:id])

        data = party.to_data_hash

        if params[:include_email]
          if params[:email_purposes].present?
            contact_purposes = params[:email_purposes].split(',')
            data[:email_addresses] = party.email_addresses_to_hash(contact_purposes)
          else
            data[:email_addresses] = party.email_addresses_to_hash
          end
        end

        if params[:include_phone_number]
          if params[:phone_number_purposes].present?
            contact_purposes = params[:phone_number_purposes].split(',')
            data[:phone_numbers] = party.phone_numbers_to_hash(contact_purposes)
          else
            data[:phone_numbers] = party.phone_numbers_to_hash
          end
        end

        if params[:include_postal_address]
          if params[:postal_address_purposes].present?
            contact_purposes = params[:postal_address_purposes].split(',')
            data[:postal_addresses] = party.postal_addresses_to_hash(contact_purposes)
          else
            data[:postal_addresses] = party.postal_addresses_to_hash
          end
        end

        data[:custom_fields] = party.custom_fields

        render :json => {success: true, party: data}
      end

      def update_roles
        ActiveRecord::Base.transaction do
          begin
            party = Party.find(params[:id])
            role_type_iids = params[:role_type_iids].split(',')

            # remove current party roles
            party.party_roles.destroy_all

            # assign new roles
            role_type_iids.each do |role_type_iid|
              role_type = RoleType.iid(role_type_iid)

              PartyRole.create(party: party, role_type: role_type)
            end

            party.updated_by_party = current_user.party
            party.save!

            render :json => {success: true}

          rescue Exception => ex
            Rails.logger.error(e.message)
            Rails.logger.error(e.backtrace.join("\n"))

            render :json => {success: false}
          end # begin
        end # transaction
      end

    end # PartiesController
  end # V1
end # Api
