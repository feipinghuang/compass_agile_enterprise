class AddActiveAndPriorityToDiscounts < ActiveRecord::Migration
  def up
    add_column :discounts, :active, :boolean unless column_exists? :discounts, :active
    add_column :discounts, :priority, :integer unless column_exists? :discounts, :priority
  end

  def down
    remove_column :discounts,:active if column_exists? :discounts, :active
    remove_column :discounts,:priority if column_exists? :discounts, :priority
  end
end
