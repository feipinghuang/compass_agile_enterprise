module ErpApp
  module Shared
    class AuditLogController < ErpApp::ApplicationController
      before_filter :require_login

      def index
        start_date = params[:start_date].to_date
        end_date = params[:end_date].to_date
        audit_log_type_id = params[:audit_log_type_id]
        event_record_type = params[:event_record_type]
        event_record_id = params[:event_record_id]

        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        sort = sort_hash[:property] || 'id'
        dir = sort_hash[:direction] || 'DESC'
        limit = params[:limit] || 15
        start = params[:start] || 0

        if start_date.blank? and end_date.blank? and audit_log_type_id.blank?
          arel_query = AuditLog
        else
          audit_logs = AuditLog.arel_table

          arel_query = AuditLog.where(:created_at => (start_date - 1.day)..(end_date + 1.day))
          arel_query = arel_query.where(audit_logs[:audit_log_type_id].eq(audit_log_type_id)) if audit_log_type_id
        end

        if event_record_type.present? && event_record_id.present?
          arel_query = arel_query.where('event_record_type = ? and event_record_id = ?', event_record_type, event_record_id)
        end

        audit_log_entries = arel_query.order("#{sort} #{dir}").offset(start).limit(limit).all

        total_count = arel_query.count

        render :json => {:total_count => total_count,
                         :audit_log_entries => audit_log_entries.collect {
                             |audit_log| audit_log.to_hash(:only => [:id, :description, :created_at],
                                                           :party_description => audit_log.party.description,
                                                           :audit_log_type => audit_log.audit_log_type.description) }}
      end

      def items
        audit_log_items = AuditLogItem.where('audit_log_id = ? ', params[:audit_log_id])

        data = audit_log_items.collect do |audit_log_item|
          audit_log_item.to_hash(:only => [:id,
                                                 :description,
                                                 :created_at,
                                                 :audit_log_id,
                                                 {:audit_log_item_value => :new_value},
                                                 {:audit_log_item_old_value => :old_value}],
                                 :audit_log_item_type => audit_log_item.try(:type).try(:description))
        end

        render :json => {:audit_log_items => data}
      end


      def audit_log_types
        audit_log_types = AuditLogType.all

        render :json => {:audit_log_types => audit_log_types.collect { |type| type.to_hash(:only => [:id, :description, :internal_identifier]) }}
      end

    end #AuditLogController
  end #Shared
end #ErpApp