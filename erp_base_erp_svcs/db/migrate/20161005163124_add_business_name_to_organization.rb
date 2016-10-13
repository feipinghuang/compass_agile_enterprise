class AddBusinessNameToOrganization < ActiveRecord::Migration
  def up
    unless column_exists? :organizations, :business_name
      add_column :organizations, :business_name, :string
    end
  end

  def down
    if column_exists? :organizations, :business_name
      remove_column :organizations, :business_name
    end
  end
end
