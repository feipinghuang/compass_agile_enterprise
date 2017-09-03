require 'spec_helper'

describe PhoneNumber do
  it "can be instantiated" do
    PhoneNumber.new(phone_number: '352.409.5555').should be_an_instance_of(PhoneNumber)
  end

  it "can be saved successfully" do
    PhoneNumber.create(phone_number: '352.409.5555').should be_persisted
  end

end
