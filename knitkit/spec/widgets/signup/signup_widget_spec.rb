require "spec_helper"

describe Widgets::Signup::Base, type: :controller do

  #create dummy controller
  controller(ApplicationController) do end

  let(:user) { FactoryGirl.create(:user) }
  let(:website) { FactoryGirl.create(:website, :configure_with_host, name: 'Test Website', host: 'localhost:3000', party: user.party) }
  let(:user_valid_params) { { first_name: 'Test', last_name: 'Test', email: 'test@example.com', username: 'test', password: 'password', password_confirmation: 'password' } }
  let(:user_invalid_params) { { first_name: '', last_name: '', email: '', username: '', password: '', password_confirmation: '' } }

  describe "GET #index" do
    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(website)
      login_url = {login_url: "/login"}
      widget = Widgets::Signup::Base.new(controller, "signup", :index, uuid, login_url, nil)
      result = widget.process('index')

      expect(result).not_to be_empty
      expect(result).to render_template(:index)
    end
  end

  describe "POST #new" do
      let!(:application_composer_role_type) { FactoryGirl.create(:role_type, description: 'Application Composer', internal_identifier: 'application_composer') }
      let!(:dba_org_role_type) { FactoryGirl.create(:role_type, description: 'Doing Business As Organization', internal_identifier: 'dba_org', parent: application_composer_role_type) }
      RoleType.iid('customer')
      let!(:customer_role_type) { FactoryGirl.create(:role_type, description: 'Customer', internal_identifier: 'customer', parent: application_composer_role_type) }
      let!(:website_role_type) { FactoryGirl.create(:role_type, description: 'Website', internal_identifier: 'website') }
      let!(:member_role_type) { FactoryGirl.create(:role_type, description: 'Member', internal_identifier: 'member', parent: website_role_type) }

    context 'with valid data' do
      it "should create user" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)
        widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, user_valid_params, nil)

        expect { widget.process('new') }.to change { User.count }.by(1)
      end
    end

    context 'with existing valid user data' do
      it "should not create user" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)
        user_valid_params[:email] = user.email
        user_valid_params[:username] = user.username

        widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, user_valid_params, nil)

        expect { widget.process('new') }.not_to change(User, :count)
      end
    end

    context 'with default RoleType' do
      it "should create user " do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)

        widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, user_valid_params, nil)
        widget.process('new')
        expect(User.last.party.role_types).not_to match_array([])
      end
    end

    context 'with specified RoleType' do
      it "should create user " do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)

        user_valid_params[:party_roles] = customer_role_type.internal_identifier

        widget = Widgets::Signup::Base.new(controller, "signup", :new, uuid, user_valid_params, nil)

        widget.process('new')
        expect(User.last.party.role_types.first.internal_identifier).to eq(customer_role_type.internal_identifier)
      end
    end
  end
end
