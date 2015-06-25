module Api
  module V1
    class PartiesController < BaseController

      def index
        query = params[:query]
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'username'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0

        if query.blank?
          parties = Party.order("#{sort} #{dir}").offset(start).limit(limit)
          total_count = parties.count
        else
          parties = Party.where('description like ?', "%#{query}%").order("#{sort} #{dir}")
          total_count = parties.count
          parties = parties.offset(start).limit(limit)
        end

        render :json => {total_count: total_count, parties: parties.collect(&:to_data_hash)}
      end

      def show
        party = Party.find(params[:id])

        render :json => {party: party.to_data_hash}
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

            # add a new relationship to the root dba_org with this role type

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