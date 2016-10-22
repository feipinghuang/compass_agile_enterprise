# create_table :notes do |t|
#   t.text :content
#   t.references :noted_record, :polymorphic => true
#   t.references :note_type
#
#   t.references :created_by_party
#   t.references :updated_by_party
# 
#   t.timestamps
# end

# add_index :notes, [:noted_record_id, :noted_record_type]
# add_index :notes, :note_type_id
# add_index :notes, :notes_updated_by_pty_idx
# add_index :notes, :notes_created_by_pty_idx
class Note < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  tracks_created_by_updated_by

  belongs_to :note_type
  belongs_to :noted_record, :polymorphic => true

  validates :content, presence: true
  validates :note_type, presence: true

  def note_type_desc
    self.note_type.description
  end

  def summary
    (content.length > 20) ? "#{content[0..20]}..." : content
  end

  def to_s
    summary
  end

end
