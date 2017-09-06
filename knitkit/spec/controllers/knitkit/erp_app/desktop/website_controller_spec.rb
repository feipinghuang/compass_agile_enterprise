require "spec_helper"
require "erp_dev_svcs"

describe Knitkit::ErpApp::Desktop::WebsiteController, type: :controller do

  before(:each) do
    basic_user_auth_with_admin
  end

  describe "Website" do
    let(:user) {User.first}

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
    end

    describe "Get index" do
      it "should return :sites => Website.all" do
        get :index, {:use_route => :knitkit,
                     :action => "index"}

        parsed_body = JSON.parse(response.body)
        parsed_body["sites"][0].should include({ "name"=>"Test Website",
                                                 "subtitle"=>nil,
                                                 "title"=>"Some Title!"})
      end
    end

    describe "Get website_publications" do
      it "should return the correct info with session[:website_version] blank" do
        get :website_publications, {:use_route => :knitkit,
                                    :action => "website_publications",
                                    :website_id => @website.id}

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)
        parsed_body["results"].should eq(1)
        parsed_body["totalCount"].should eq(1)
        parsed_body["data"][0]["active"].should eq(true)
        parsed_body["data"][0]["comment"].should eq("New Site Created")
        parsed_body["data"][0]["version"].should eq("0.0")
        parsed_body["data"][0]["viewing"].should eq(true)
        parsed_body["data"][0]["published_by_username"].should eq("")
        parsed_body["data"][0]["created_at"].should be_a(String)
      end

      it "should return the correct info with session[:website_version] not blank" do
        session[:website_version] = [{:website_id => @website.id, :version => "1.0"}]
        get :website_publications, {:use_route => :knitkit,
                                    :action => "website_publications",
                                    :website_id => @website.id}

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)
        parsed_body["results"].should eq(1)
        parsed_body["totalCount"].should eq(1)
        parsed_body["data"][0]["active"].should eq(true)
        parsed_body["data"][0]["comment"].should eq("New Site Created")
        parsed_body["data"][0]["version"].should eq("0.0")
        parsed_body["data"][0]["viewing"].should eq(false)
        parsed_body["data"][0]["published_by_username"].should eq("")
        parsed_body["data"][0]["created_at"].should be_a(String)
      end
    end

    describe "Post activate_publication" do
      it "should call set_publication_version with version number on website and return success:true" do
        @website.published_websites << FactoryGirl.create(:published_website,
                                                          :version => 1,
                                                          :comment => "published_website test",
                                                          :published_by_id => 1)

        Website.should_receive(:find).and_return(@website)
        @website.should_receive(:set_publication_version).with(1.0, @user)

        post :activate_publication, {:use_route => :knitkit,
                                     :action => "activate_publication",
                                     :website_id => @website.id,
                                     :version => "1.0"}

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)
      end
    end

    describe "Post set_viewing_version" do
      it "should set session[:website_version] properly when session[:website_version] is blank" do
        post :set_viewing_version, {:use_route => :knitkit,
                                    :action => "set_viewing_version",
                                    :website_id => @website.id,
                                    :version => "1.0"}

        session[:website_version].should include({:website_id => @website.id, :version => "1.0"})
      end

      it "should set session[:website_version] properly when session[:website_version] is not blank" do
        session[:website_version]=[]
        session[:website_version] << {:website_id => @website.id, :version => "2.0"}

        post :set_viewing_version, {:use_route => :knitkit,
                                    :action => "set_viewing_version",
                                    :website_id => @website.id,
                                    :version => "1.0"}

        session[:website_version].should include({:website_id => @website.id, :version => "1.0"})
      end

      it "should return success:true" do
        post :set_viewing_version, {:use_route => :knitkit,
                                    :action => "set_viewing_version",
                                    :website_id => @website.id,
                                    :version => "1.0"}

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)
      end
    end

    describe "Post publish" do
      it "should call publish on @website and return success:true" do
        Website.should_receive(:find).and_return(@website)
        @website.should_receive(:publish)

        post :publish, {:use_route => :knitkit,
                        :action => "publish",
                        :website_id => @website.id,
                        :comment => "some comment"}

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)
      end
    end

    describe "update" do
      it "should set new params and return true" do
        Website.should_receive(:find).and_return(@website)

        post :update, {
          :use_route => :knitkit,
          :action => "update",
          :website_id => @website.id,
          :subtitle =>  "some new sub title",
          :title => "some new title",
          :name => "some new name"
        }

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)

        @website.name.should eq("some new name")
        @website.title.should eq("some new title")
        @website.subtitle.should eq("some new sub title")
      end
    end

    describe "delete" do
      it "should destroy @website" do
        post :delete, {:use_route => :knitkit,
                       :action => "delete",
                       :website_id => @website.id}

        parsed_body = JSON.parse(response.body)
        parsed_body["success"].should eq(true)
      end
    end

    after(:all) do
      if @website
        @website.destroy
      end
    end

  end

  describe "Post new" do
    it "should create a new Website with name some name and set each param for that Website" do
      post :new, {
        :use_route => :knitkit,
        :action => "new",
        :host => "localhost:3001",
        :subtitle =>  "some sub title",
        :title => "some title",
        :name => "some name"
      }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)

      new_website = Website.find_by_name("some name")
      new_website.subtitle.should  eq("some sub title")
      new_website.title.should  eq("some title")
    end

    it "should create a WebsiteSection named home and link it to website" do
      post :new, {
        :use_route => :knitkit,
        :action => "new",
        :host => "localhost:3001",
        :subtitle =>  "some sub title",
        :title => "some title",
        :name => "some name"
      }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)

      home_section_exists = false
      new_website = Website.find_by_name("some name")
      new_website.website_sections.each do |section|
        home_section_exists = true if section.internal_identifier == "home"
      end

      home_section_exists.should eq(true)
    end

    it "should create a host and assign it to website.hosts" do
      post :new, {
        :use_route => :knitkit,
        :action => "new",
        :host => "localhost:3001",
        :subtitle =>  "some sub title",
        :title => "some title",
        :name => "some name"
      }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)

      new_website = Website.find_by_name("some name")

      new_website.hosts.each do |host|
        host.host.should eq("localhost:3001")
      end
    end

    it "should publish website" do
      post :new, {
        :use_route => :knitkit,
        :action => "new",
        :host => "localhost:3001",
        :subtitle =>  "some sub title",
        :title => "some title",
        :name => "some name"
      }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)

      new_website = Website.find_by_name("some name")
      new_website.published_websites.count.should eq(2)
    end

    it "should activate the new publication" do
      post :new, {
        :use_route => :knitkit,
        :action => "new",
        :host => "localhost:3001",
        :subtitle =>  "some sub title",
        :title => "some title",
        :name => "some name"
      }

      parsed_body = JSON.parse(response.body)
      parsed_body["success"].should eq(true)

      new_website = Website.find_by_name("some name")
      active_website = new_website.published_websites.find_by_active(true)
      active_website.version.should eq(1.0)
    end

    after(:each) do
      new_website = Website.find_by_name("some name")
      if new_website
        new_website.destroy
      end
    end
  end

end
