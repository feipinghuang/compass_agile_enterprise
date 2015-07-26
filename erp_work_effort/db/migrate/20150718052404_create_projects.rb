class CreateProjects < ActiveRecord::Migration

  def self.up
    unless table_exists?(:projects)
      create_table :projects do |t|
        t.string   :description
        t.column   :project_record_id, :integer
        t.column   :project_record_type, :string
        t.timestamps
      end
    end
  end

  def self.down
    if table_exists?(:projects)
      drop_table :projects
    end
  end

end
