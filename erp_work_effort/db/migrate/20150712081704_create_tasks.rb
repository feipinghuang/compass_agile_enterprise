class CreateTasks < ActiveRecord::Migration

  def self.up
    unless table_exists?(:tasks)
      create_table :tasks do |t|
        t.string   :description
        t.text     :content
        t.datetime :start
        t.datetime :end
        t.column   :task_type_id, :integer
        t.column   :project_id, :integer
        t.column   :task_record_id, :integer
        t.column   :task_record_type, :string
        t.timestamps
      end
    end

    unless table_exists?(:task_types)
      create_table :task_types do |t|
        t.integer :parent_id
        t.integer :lft
        t.integer :rgt

        #custom columns go here
        t.string :description
        t.string :comments
        t.string :internal_identifier
        t.string :external_identifier
        t.string :external_id_source

        t.timestamps
      end
    end

  end

  def self.down
    if table_exists?(:tasks)
      drop_table :tasks
    end
    if table_exists?(:task_types)
      drop_table :task_types
    end
  end

end
