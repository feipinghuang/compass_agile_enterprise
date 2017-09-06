require 'spec_helper'

describe Application do
  it "can be instantiated" do
    Application.new.should be_an_instance_of(Application)
  end

  it "can be saved successfully" do
    Application.create(:internal_identifier => 'test').should be_persisted

    Application.find_by_internal_identifier('test').destroy
  end
end
