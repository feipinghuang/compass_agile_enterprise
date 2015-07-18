class CreateTasks < ActiveRecord::Migration

  def self.up
    unless table_exists?(:tasks)
      create_table :tasks do |t|
        t.string   :description
        t.text     :content
        t.datetime :start
        t.datetime :end
        t.boolean  :unread
        t.column   :project_id, :integer
        t.column   :task_record_id, :integer
        t.column   :task_record_type, :string
        t.timestamps
      end
    end

  end

  def self.down
    if table_exists?(:tasks)
      drop_table :tasks
    end
  end

end
