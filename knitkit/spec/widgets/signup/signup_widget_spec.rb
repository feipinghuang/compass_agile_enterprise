require "spec_helper"

describe Widgets::Signup::Base, type: :controller do

  #create dummy controller
  controller(ApplicationController) do end

  before(:all) do
    @website = FactoryGirl.create(:website, name: "Test Website")

    FactoryGirl.create(:website_party_role,
                       website: @website,
                       party: Party.find_by_description('CompassAE'),
                       role_type: RoleType.iid('dba_org'))

    @website.hosts << WebsiteHost.create(:host => 'localhot:3000')
    @website.configurations.first.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('primary_host'), 'localhot:3000')
    @website.save

    @website.hosts << FactoryGirl.create(:website_host)
    @role_type = FactoryGirl.create(:role_type)
    @user = FactoryGirl.create(:user)
  end

  before(:each) do
    @user_data = {
      first_name: 'Test',
      last_name: 'Test',
      email: 'Test@Test.com',
      username: 'test',
      password: 'password',
      password_confirmation: 'password',
    }
  end

  describe "Get index" do
    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      login_url = {login_url: "/login"}
      widget = Widgets::Signup::Base.new(controller, "signup", :index, uuid, login_url, nil)

      result = widget.process('index')
      expect result.should =~ /class="form-signin"/
    end
  end

  describe "Get new" do

    it "should create user" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, @user_data, nil)

      expect{
        widget.process('new')
      }.to change {User.count}
    end

    it "should not create duplicate user" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @user_data[:email] = @user.email,
      @user_data[:username] = @user.username,

      widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, @user_data, nil)

      expect {
        widget.process('new')
      }.not_to change {User.count}
    end

    it "should create user with default RoleType" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, @user_data, nil)
      widget.process('new')
      expect(User.last.party.role_types).not_to match_array([])
    end

    it "should create user with specified RoleType" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @user_data[:party_roles] = @role_type.internal_identifier

      widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, @user_data, nil)

      widget.process('new')
      expect(User.last.party.role_types.first.internal_identifier).to eq(@role_type.internal_identifier)
    end
  end

  after(:all) do
    @website.destroy if @website
    @user.destroy if @user
  end
end