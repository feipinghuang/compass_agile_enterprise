class AddTenantIdToAgreements < ActiveRecord::Migration
  def up
    %w{agreements agreement_types agreement_item_types loyalty_program_codes}.each do |table|
      unless column_exists? table, :tenant_id
        add_column table, :tenant_id, :integer

        add_index table, :tenant_id, name: "#{table}_tenant_idx"
      end
    end
  end

  def down
  	%w{agreements agreement_types agreement_item_types loyalty_program_codes}.each do |table|
      if column_exists? table, :tenant_id
        remove_column table, :tenant_id
      end
    end
  end
end
