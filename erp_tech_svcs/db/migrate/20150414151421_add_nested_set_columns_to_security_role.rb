class AddNestedSetColumnsToSecurityRole < ActiveRecord::Migration
  def change
    add_column :security_roles, :lft, :integer unless column_exists?(:security_roles, :lft)
    add_column :security_roles, :rgt, :integer unless column_exists?(:security_roles, :rgt)
    add_column :security_roles, :parent_id, :integer unless column_exists?(:security_roles, :parent_id)

    add_index :security_roles, :parent_id unless index_exists?(:security_roles, :parent_id)
    add_index :security_roles, :lft unless index_exists?(:security_roles, :lft)
    add_index :security_roles, :rgt unless index_exists?(:security_roles, :rgt)

    SecurityRole.rebuild!
  end
end
