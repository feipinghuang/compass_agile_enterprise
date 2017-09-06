require "spec_helper"
require "erp_dev_svcs"

describe Knitkit::ErpApp::Desktop::WebsiteHostController do
  before(:each) do
    basic_user_auth_with_admin
    @website = FactoryGirl.create(:website, :name => "Some name")
    @website.hosts << FactoryGirl.create(:website_host)
  end

  describe "Post add_host" do
    it "should return success:true and node" do
      @website_host = FactoryGirl.create(:website_host, :host => "localhost:3000")

      WebsiteHost.should_receive(:create).and_return(@website_host)

      post :add_host, {:use_route => :knitkit,
                       :action => "add_host",
                       :id => @website.id,
                       :host => "localhost:3000"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)

      parsed_body["node"].should include(
        {"text" => "localhost:3000",
         "websiteHostId" => @website_host.id,
         "host" => "localhost:3000",
         "iconCls" => 'icon-globe',
         "url" => "http://localhost:3000",
         "isHost" => true,
         "leaf" => true,
         "children" => []})
    end
  end

  describe "Post update_host" do
    it "should set host and save" do
      @website_host = FactoryGirl.create(:website_host, :host => "some host")
      WebsiteHost.should_receive(:find).and_return(@website_host)
      @website_host.should_receive(:save)

      post :update_host, {:use_route => :knitkit,
                          :action => "update_host",
                          :id => @website.id,
                          :host => "localhost:3000"}

      @website_host.host.should eq("localhost:3000")
    end

    it "should return success:true" do
      post :update_host, {:use_route => :knitkit,
                          :action => "update_host",
                          :id => @website.id,
                          :host => "localhost:3000"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

  describe "Post delete_host" do
    it "should call destroy on WebsiteHost with params[:id]" do
      WebsiteHost.should_receive(:destroy).with("1")

      post :delete_host, {:use_route => :knitkit,
                          :action => "delete_host",
                          :id => "1"}
    end

    it "should return success:true" do
      post :delete_host, {:use_route => :knitkit,
                          :action => "delete_host",
                          :id => "1"}

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)
    end
  end

end
