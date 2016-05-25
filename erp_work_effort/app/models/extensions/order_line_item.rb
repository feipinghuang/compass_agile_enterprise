OrderLineItem.class_eval do

  has_many :candidate_submissions, :dependent => :destroy
  has_many :work_order_item_fulfillments, :dependent => :destroy
  has_many :work_efforts, through: :work_order_item_fulfillments

end
