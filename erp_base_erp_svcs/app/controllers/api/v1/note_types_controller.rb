module Api
  module V1
    class NoteTypesController < BaseController

      def index
        if params[:ids]
          NoteType.include_root_in_json = false

          render json: {note_types: NoteType.where(id: params[:ids].split(',')).all}
        else
          NoteType.include_root_in_json = false

          render json: {note_types: NoteType.all}
        end
      end

    end # NoteTypesController
  end # V1
end # Api