# create_table :notifications do |t|
#   t.string :type
#   t.references :created_by
#   t.text :message
#   t.references :notification_type
#   t.string :current_state
#   t.text :custom_fields
#
#   t.timestamps
# end
#
# add_index :notifications, :notification_type_id
# add_index :notifications, :created_by_id
# add_index :notifications, :type

class Notification < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to :notification_type
  belongs_to :created_by, :foreign_key => 'created_by_id', :class_name => 'Party'

  # serialize custom attributes
  is_json :custom_fields

  include AASM

  aasm_column :current_state

  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :notification_delivered

  aasm_event :delivered_notification do
    transitions :to => :notification_delivered, :from => [:pending]
  end

  class << self

    # Creates a Notification record with the notification type passed
    #
    # @param [NotificationType | String] the notification type to set, can be a NotificationType record or InternalIdentifier
    # @param [Hash] custom fields to set on the notification
    # @param [Party] the party that created the notification
    def create_notification_of_type(notification_type, custom_fields={}, created_by=nil)
      notification_type = notification_type.class == NotificationType ? notification_type : NotificationType.iid(notification_type)

      notification = self.create(
          created_by: created_by,
          notification_type: notification_type
      )

      notification.custom_fields = custom_fields

      notification.save!

      notification
    end

  end

  # Delivers notification, called by the notifications delayed job
  # this is a template method and should be overridden by sub class
  def deliver_notification
  end

end
