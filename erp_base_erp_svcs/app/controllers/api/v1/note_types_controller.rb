module API
  module V1
    class NoteTypesController < BaseController

=begin

 @api {get} /api/v1/note_types
 @apiVersion 1.0.0
 @apiName GetNoteTypes
 @apiGroup NoteType
 @apiDescription Get NoteTypes

 @apiSuccess (200) {Object} get_note_types_response Response
 @apiSuccess (200) {Boolean} get_note_types_response.success True if the request was successful
 @apiSuccess (200) {Number} get_note_types_response.total_count Total count of records based on any filters applied
 @apiSuccess (200) {Object[]} get_note_types_response.note_types NoteType records
 @apiSuccess (200) {Number} get_note_types_response.note_types.id Id of NoteType

=end      

      def index
        NoteType.include_root_in_json = false

        if params[:ids]
          note_types = NoteType.where(id: params[:ids].split(',')).all

          render json: {success: true, total_count: note_types.count, note_types: note_types}
        else
          note_types = NoteType.all

          render json: {success: true, total_count: note_types.count, note_types: note_types}
        end
      end

=begin

 @api {get} /api/v1/note_types/:id
 @apiVersion 1.0.0
 @apiName GetNoteType
 @apiGroup NoteType
 @apiDescription Get NoteType

 @apiParam (path) {Integer} id Id of NoteType

 @apiSuccess (200) {Object} get_note_type_response Response
 @apiSuccess (200) {Boolean} get_note_type_response.success True if the request was successful
 @apiSuccess (200) {Object[]} get_note_type_response.note_types NoteType records
 @apiSuccess (200) {Number} get_note_type_response.note_types.id Id of NoteType

=end

      def show
        NoteType.include_root_in_json = false

        note_type = NoteType.find(params[:id])

        render json: {success: true, note_type: note_type}
      end

    end # NoteTypesController
  end # V1
end # API
