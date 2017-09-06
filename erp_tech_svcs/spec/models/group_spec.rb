require 'spec_helper'

describe Group do

  before(:all) do
    @role = SecurityRole.create(:description => "Test Role", :internal_identifier => 'test role')
    @group = Group.create(:description => "Test Group")
    @user = FactoryGirl.create(:user)
    @capability = FileAsset.add_capability('upload')
  end

  it "should allow you to add and remove roles" do
    @group.has_role?(@role).should eq false
    @group.add_role(@role)
    @group.has_role?(@role).should eq true
    @group.remove_role(@role)
    @group.has_role?(@role).should eq false
  end

  it "should allow you to add and remove capabilities" do
    @group.capabilities.include?(@capability).should eq false
    @group.add_capability(@capability)
    @group.capabilities.include?(@capability).should eq true
    @group.remove_capability(@capability)
    @group.capabilities.include?(@capability).should eq false
  end

  it "should allow you to add and remove users" do
    @group.users.include?(@user).should eq false
    @group.add_user(@user)
    @group.users.include?(@user).should eq true
    @group.remove_user(@user)
    @group.users.include?(@user).should eq false
  end

  after(:all) do
    @group.destroy
    @user.destroy
    @role.destroy
    @capability.destroy
  end

end
