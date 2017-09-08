require "spec_helper"

describe Widgets::Signup::Base, :type => :controller do

  #create dummy controller
  controller do end

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

    @user = FactoryGirl.create(:user)
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
      user_data = {
        first_name: 'Test',
        last_name: 'Test',
        email: 'Test@Test.com',
        username: 'test',
        password: 'password',
        password_confirmation: 'password',
      }

      widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, user_data, nil)

      result = widget.process('new')
      expect result[:json][:success].should eq(true)
    end

    it "should not create duplicate user" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      user_data = {
        first_name: 'Test',
        last_name: 'Test',
        email: @user.email,
        username: @user.username,
        password: 'password',
        password_confirmation: 'password',
      }

      widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, user_data, nil)

      result = widget.process('new')
      expect result[:json][:success].should eq(true)
    end
  end

  after(:all) do
    @website.destroy if @website
    @user.destroy if @user
  end
end