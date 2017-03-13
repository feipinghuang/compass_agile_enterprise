class CreateAccountsProjects < ActiveRecord::Migration
  def up
    unless table_exists? :biz_txn_acct_roots_projects
      create_table :biz_txn_acct_roots_projects do |t|
        t.references :project
        t.references :biz_txn_acct_root
      end

      add_index :biz_txn_acct_roots_projects, :project_id, name: 'biz_txn_acct_root_project_project_id'
      add_index :biz_txn_acct_roots_projects, :biz_txn_acct_root_id, name: 'biz_txn_acct_root_project_acct_id'
    end
  end

  def down
    if table_exists? :biz_txn_acct_roots_projects
      drop_table biz_txn_acct_roots_projects
    end
  end
end
