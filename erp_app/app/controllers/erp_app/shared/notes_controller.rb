module ErpApp
  module Shared
    class NotesController < ErpApp::ApplicationController
      before_filter :require_login

      def index
        sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
        limit = params[:limit] || 30
        start = params[:start] || 0

        sort = sort_hash[:property] || 'created_at'
        dir = sort_hash[:direction] || 'DESC'

        statement = Note

        if params[:record_id] && params[:record_type]
          statement = Note.where('noted_record_id = ? and noted_record_type = ?', params[:record_id], params[:record_type])
        end

        total = statement.count('id')
        notes = statement.limit(limit).offset(start).order("#{sort} #{dir}")

        render :json => {totalCount: total, notes: notes.collect { |note| note.to_hash(only: [:id, :content, :created_at], methods: [:summary, :note_type_desc, :created_by_username]) }}
      end

      def create
        begin
          ActiveRecord::Base.transaction do
            content = params[:content]
            note_type = NoteType.find(params[:note_type_id])
            record_type = params[:record_type]
            record_id = params[:record_id]

            Note.create(
                :note_type => note_type,
                :content => content,
                :noted_record_type => record_type,
                :noted_record_id => record_id,
                :created_by_id => current_user.party.id
            )

            render :json => {:success => true}
          end
        rescue => ex
          logger.error ex.message
          logger.error ex.backtrace.join("\n")

          render :json => {:success => false, message: ex.message}
        end
      end

      def destroy
        Note.find(params[:id]).destroy ? (render :json => {:success => true}) : (render :json => {:success => false})
      end

    end # NotesController
  end # Shared
end # ErpApp
