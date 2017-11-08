class CreateDiscounts < ActiveRecord::Migration
  def change
    unless table_exists?(:discounts)
      create_table :discounts do |t|
        t.string    :description
        t.string    :discount_type
        t.decimal   :amount
        t.boolean   :date_constrained
        t.datetime  :valid_from
        t.datetime  :valid_thru
        t.boolean   :round
        t.integer   :round_amount
        t.integer   :created_by_party_id
        t.integer   :updated_by_party_id

        t.timestamps
      end
    end
    # associative table that relates discounts to product types
    unless table_exists?(:product_type_discounts)
      create_table :product_type_discounts do |t|
        t.integer   :discount_id
        t.integer   :product_type_id

        t.timestamps
      end
    end
  end
end
