class CommEvtPurposeType < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_and_belongs_to_many :communication_events,
    :join_table => 'comm_evt_purposes'

  def to_label
    "#{description}"
  end

  def to_s
    "#{description}"
  end

  class << self
    def iid(internal_identifier)
      self.find_by_internal_identifier(internal_identifier)
    end

    def find_or_create(internal_identifier, description)
      activity_stream_entry_type = self.iid(internal_identifier)

      unless activity_stream_entry_type
        activity_stream_entry_type = CommEvtPurposeType.create(
            internal_identifier: internal_identifier,
            description: description
        )
      end

      activity_stream_entry_type
    end
  end

end
