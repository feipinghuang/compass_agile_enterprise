class AddCustomFieldsToErpAgreements < ActiveRecord::Migration
  def up
    %w{agreements agreement_types}.each do |table|
      unless column_exists? table, :custom_fields
        add_column table, :custom_fields, :text
      end
    end
  end

  def down
    %w{agreements agreement_types}.each do |table|
      if column_exists? table, :custom_fields
        remove_column table, :custom_fields
      end
    end
  end
end
