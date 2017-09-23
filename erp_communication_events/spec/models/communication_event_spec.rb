require 'spec_helper'

describe CommunicationEvent do
  it "can be instantiated" do
    CommunicationEvent.new.should be_an_instance_of(CommunicationEvent)
  end

  it "can be saved successfully" do
    CommunicationEvent.create(short_description: 'test').should be_persisted
  end
end
