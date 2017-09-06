require "spec_helper"
require "erp_dev_svcs"

describe Knitkit::ErpApp::Desktop::WebsiteSectionController do

  let(:user) {User.first}

  before(:each) do
    basic_user_auth_with_admin
  end

  before(:all) do
    @website = FactoryGirl.create(:website, name: "Test Website")

    FactoryGirl.create(:website_party_role,
                       website: @website,
                       party: Party.find_by_description('CompassAE'),
                       role_type: RoleType.iid('dba_org'))

    @website.hosts << WebsiteHost.create(:host => 'localhot:3000')
    @website.configurations.first.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('primary_host'), 'localhot:3000')
    @website.save!

    @website.hosts << FactoryGirl.create(:website_host)
  end

  describe "POST new" do

    it "should create a new website section" do
      post :new, {:use_route => :knitkit,
                  :action => "new",
                  :website_id => @website.id,
                  :title => "Some New Title",
                  internal_identifier: 'test1'}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)

      WebsiteSection.find_by_internal_identifier('test1').destroy
    end

    it "title can not be 'blog' if section is a blog" do
      post :new, {:use_route => :knitkit,
                  :action => "new",
                  :website_id => @website.id,
                  :title => "Blog",
                  :type => "Blog"}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(false)
    end

    it "can be a child of another section" do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
      post :new, {:use_route => :knitkit,
                  :action => "new",
                  :website_id => @website.id,
                  :title => "Some New Title",
                  internal_identifier: 'test1',
                  :website_section_id => @website_section.id}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)

      WebsiteSection.find_by_internal_identifier('test1').destroy
    end


    it "should fail to save if no title is given" do
      post :new, {:use_route => :knitkit,
                  :action => "new",
                  :website_id => @website.id}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(false)
    end
  end

  describe "Post delete" do
    before(:each) do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
    end

    it "should delete the given section" do
      post :delete, {:use_route => :knitkit,
                     :action => "delete",
                     :id => @website_section.id}
      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
    end
  end

  describe "Post update_security" do
    before(:all) do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
    end

    it "should secure the section given secure = true" do

      post :update_security, {:use_route => :knitkit,
                              :action => "update_security",
                              :id => @website_section.id,
                              :site_id => @website.id,
                              :security => ['admin'].to_json}
    end

    it "should unsecure the section given secure = false" do

      post :update_security, {:use_route => :knitkit,
                              :action => "update_security",
                              :id => @website_section.id,
                              :site_id => @website.id,
                              :security => [].to_json}
    end

    after(:all) do
      @website_section.destroy
    end

  end

  describe "Post update" do
    before(:all) do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
    end

    it "should save" do
      post :update, {:use_route => :knitkit,
                     :action => "update",
                     :id => @website_section.id,
                     :in_menu => "yes",
                     :title => "some title",
                     :internal_identifier => "some-title"}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
    end

    it "should return false if website_section.save returns false" do
      post :update, {:use_route => :knitkit,
                     :action => "update",
                     :id => @website_section.id,
                     :in_menu => "yes",
                     :internal_identifier => "some-title"}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(false)
    end

    after(:all) do
      @website_section.destroy
    end
  end

  describe "Post add_layout" do

    it "should call create_layout" do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
      @website_section_double = double("WebsiteSection")
      WebsiteSection.should_receive(:find).and_return(@website_section_double)
      @website_section_double.should_receive(:create_layout)

      post :add_layout, {:use_route => :knitkit,
                         :action => "add_layout",
                         :id => @website_section.id}
    end
  end

  describe "Get get_layout" do
    it "should call layout" do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
      @website_section_double = double("WebsiteSection")
      WebsiteSection.should_receive(:find).and_return(@website_section_double)
      @website_section_double.should_receive(:layout)

      get :get_layout, {:use_route => :knitkit,
                        :action => "get_layout",
                        :id => @website_section.id}
    end
  end

  describe "Post save_layout" do
    before(:each) do
      @website_section = FactoryGirl.create(:website_section)
      @website.website_sections << @website_section
    end

    it "should save layout" do
      post :save_layout, {:use_route => :knitkit,
                          :action => "save_layout",
                          :id => @website_section.id,
                          :content => "some text"}

      parsed_res = JSON.parse(response.body)
      parsed_res['success'].should eq(true)
    end
  end

  describe "Get existing_sections" do
    it "should call website.sections.to_json with :only => [:id], :methods => [:title_permalink]" do
      @website_section = FactoryGirl.create(:website_section, :title => "some_title")
      @website.website_sections << @website_section

      get :existing_sections, {:use_route => :knitkit,
                               :action => "existing_sections",
                               :website_id => @website.id}

      parsed_res = JSON.parse(response.body)
      parsed_res[0]["id"].should eq(@website_section.id)
      parsed_res[0]["title_permalink"].should eq("some_title - /")
    end
  end

  after(:all) do
    @website.destroy
  end

end
