module ErpBaseErpSvcs
	module Extensions
		module ActiveRecord
			module HasNotes

				def self.included(base)
				  base.extend(ClassMethods)
				end

				module ClassMethods
				  def has_notes

            has_many :notes, :as => :noted_record, :dependent => :delete_all do
              def by_type(note_type_iid)
                where('note_type_id = ?', NoteType.iid(note_type_iid))
              end

            end
					
            extend SingletonMethods
            include InstanceMethods

				  end
				end

				module SingletonMethods
				end

				module InstanceMethods

          # adds note to model
          def add_note(note_type_iid, content, party=nil)
            note = Note.new
            note.note_type = NoteType.iid(note_type_iid)
            note.noted_record = self
            note.created_by_party = party unless party.nil?
            note.content = content
            note if note.save
          end

          def create_or_update_note_by_type(note_type_iid='basic_note', content='', party=nil)
            note = note_by_type(note_type_iid)
            if note.nil?
              note = Note.new if note.nil?
              note.note_type_id = NoteType.find_by_internal_identifier(note_type_iid).id
              note.noted_record = self
              note.created_by_party = party unless party.nil?
            end
            note.content = content
            note.save
          end

          def note_by_type(note_type_iid)
            note_type = NoteType.find_by_internal_identifier(note_type_iid)
            notes.where(:note_type_id => note_type.id).first
          end

          def notes_by_type(note_type_iid)
            note_type = NoteType.find_by_internal_identifier(note_type_iid)
            notes.where(:note_type_id => note_type.id)
          end

				end
        
			end # HasNotes
		end # ActiveRecord
	end # Extensions
end # ErpBaseErpSvcs
