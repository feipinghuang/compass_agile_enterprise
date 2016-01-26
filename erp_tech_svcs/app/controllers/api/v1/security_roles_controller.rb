module Api
  module V1
    class SecurityRolesController < BaseController

      def index
        query = params[:query]
        parent_iids = params[:parent]
        include_admin = params[:include_admin]
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'id'
        dir = sort_hash[:direction] || 'ASC'
        limit = params[:limit] || 25
        start = params[:start] || 0

        security_roles = []

        if parent_iids
          parent = nil

          # if the parent param is a comma separated string then
          # there are multiple parents
          parent_iids.split(',').each do |parent_iid|
            parent = nil

            # if the parent param is a colon separated string then
            # the parent is nested from left to right
            parent_iid.split(':').each do |nested_parent_iid|
              if parent
                parent = SecurityRole.find_or_create(nested_parent_iid, nested_parent_iid.humanize, parent)
              else
                parent = SecurityRole.find_or_create(nested_parent_iid, nested_parent_iid.humanize)
              end
            end

            security_roles = security_roles.concat parent.children
          end

          security_roles = SecurityRole.where(id: security_roles.collect(&:id))
        else
          security_roles = SecurityRole
        end

        if query
          security_role_tbl = SecurityRole.arel_table
          statement = security_roles.where(security_role_tbl[:description].matches("%#{query}%")
                                             .or(security_role_tbl[:internal_identifier].matches("%#{query}%")))

          total_count = statement.count
          security_roles = statement.order("#{sort} #{dir}").offset(start).limit(limit)
        else
          total_count = security_roles.count
          security_roles = security_roles.order("#{sort} #{dir}").offset(start).limit(limit)
        end

        if include_admin
          security_roles = security_roles.all
          security_roles.unshift SecurityRole.iid('admin')
        end

        render :json => {success: true, total_count: total_count, security_roles: security_roles.collect(&:to_data_hash)}
      end

    end # SecurityRolesController
  end # V1
end # Api