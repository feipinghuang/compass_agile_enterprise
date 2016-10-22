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
