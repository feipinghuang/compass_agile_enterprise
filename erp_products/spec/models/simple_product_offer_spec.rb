require 'spec_helper'

describe ProductDiscountOffer do
  it "can be instantiated" do
    ProductDiscountOffer.new.should be_an_instance_of(ProductDiscountOffer)
  end

  it "can be saved successfully" do
    ProductDiscountOffer.create().should be_persisted
  end
end



