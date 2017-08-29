class PricingPlanAssignment < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  belongs_to  :pricing_plan
  belongs_to  :priceable_item, :polymorphic => true

  def to_data_hash
    data = to_hash(only: [:id, :created_at, :updated_at, :priceable_item_id, :priceable_item_type])

    data[:pricing_plan] = self.pricing_plan.to_data_hash

    data
  end

end
