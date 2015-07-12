class CreateTasks < ActiveRecord::Migration

  def self.up
    unless table_exists?(:tasks)
      create_table :tasks do |t|
        t.string  :description
        t.text    :content
        t.datetime :start
        t.datetime :end
        t.text    :custom_fields
        t.timestamps
      end
    end

    unless table_exists?(:task_party_role_types)
      create_table :task_party_role_types do |t|
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

    unless table_exists?(:task_party_roles)
      create_table :task_party_roles do |t|
        t.column :task_id, :integer
        t.column :party_id, :integer
        t.column :task_party_role_type_id, :integer
        t.timestamps
      end
      add_index :task_party_roles, :party_id
      add_index :task_party_roles, :task_party_role_type_id
    end


  end

  def self.down
    if table_exists?(:tasks)
      drop_table :tasks
    end
    if table_exists?(:task_party_role_types)
      drop_table :task_party_role_types
    end
    if table_exists?(:task_party_roles)
      drop_table :task_party_roles
    end
  end

end
