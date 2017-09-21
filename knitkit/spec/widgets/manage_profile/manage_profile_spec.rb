require "spec_helper"

describe Widgets::ManageProfile::Base, :type => :controller do

  #create dummy controller
  controller(ApplicationController) do end

  before(:each) do
    @user = FactoryGirl.create(:user)
    @individual = FactoryGirl.create(:individual)
    @user.party = @individual.party
    relationship_type = RelationshipType.find_or_create(RoleType.iid('dba_org'), FactoryGirl.create(:role_type))
    @user.party.create_relationship(relationship_type.description, Party.find_by_description('CompassAE').id, relationship_type)
  end

  describe "Get index" do

    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(User).to receive(:find).and_return(@user)

      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :index, uuid, {}, nil)

      result = widget.process('index')
      expect(result).to render_template(:index)
    end
  end

  describe "Update user information" do
    it "should update user information" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(User).to receive(:find).and_return(@user)

      user_info = {
        first_name: 'Test',
        last_name: 'Test',
        middle_name: 'Test',
        email: 'Test@Test.com'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :update_user_information, uuid, user_info, nil)
      result = widget.process('update_user_information')
      expect(result[:json][:html]).to render_template(:success)
    end

    it "should not update user information to blank" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(User).to receive(:find).and_return(@user)

      user_info = {
        first_name: '',
        last_name: '',
        middle_name: '',
        email: ''
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :update_user_information, uuid, user_info, nil)
      result = widget.process('update_user_information')
      expect(result[:json][:html]).to render_template(:error)
    end
  end

  describe "Update user password" do
    it "should update user password" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(User).to receive(:authenticate).and_return(@user)
      login_user(@user)
      user_password = {
        old_password: 'password',
        new_password: 'password',
        password_confirmation: 'password'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :update_password, uuid, user_password, nil)
      result = widget.process('update_password')
      expect(result[:json][:html]).to render_template(:success)
    end

    it "should not update user password when password and password_confirmation don't match" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(User).to receive(:authenticate).and_return(@user)
      login_user(@user)
      user_password = {
        old_password: 'password',
        new_password: 'password',
        password_confirmation: 'password1'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :update_password, uuid, user_password, nil)
      result = widget.process('update_password')
      expect(result[:json][:html]).to render_template(:error)
    end

    it "should not update password when current password doesn't match" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      user_password = {
        old_password: 'password1',
        new_password: 'password',
        password_confirmation: 'password'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :update_password, uuid, user_password, nil)
      result = widget.process('update_password')
      expect(result[:json][:html]).to render_template(:error)
    end

    it "should not update invalid password" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(User).to receive(:authenticate).and_return(@user)
      login_user(@user)
      user_password = {
        old_password: 'password',
        new_password: 'pass',
        password_confirmation: 'pass'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :update_password, uuid, user_password, nil)
      result = widget.process('update_password')
      expect(result[:json][:html]).to render_template(:error)
    end
  end

  describe "Add email Address" do
    it "should add email" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      email_info = {
        email_address: 'test123@test.com',
        contact_purpose: 'default'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :add_email_address, uuid, email_info, nil)
      result = widget.process('add_email_address')
      expect(result[:json][:message]).to match /Email added/
    end

    it "should not add invalid email address" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      email_info = {
        email_address: 'test123',
        contact_purpose: 'default'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :add_email_address, uuid, email_info, nil)
      result = widget.process('add_email_address')
      expect(result[:json][:message]).to match /Could not add email/
    end
  end

  describe "Remove email Address" do
    it "should remove email address" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      @user.party.add_contact(EmailAddress,{email_address: 'test123@test.com'},ContactPurpose.find_by_internal_identifier('default'))
      email_info = {
        email_address_id: EmailAddress.last.id.to_s,
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :remove_email_address, uuid, email_info, nil)
      result = widget.process('remove_email_address')
      expect(result[:json][:message]).to match /Email removed/
    end
  end

  describe "Add Phone number" do
    it "should add new Phone number" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      phone_info = {
        phone_number: '9876543210',
        contact_purpose: 'default'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :add_phone_number, uuid, phone_info, nil)
      result = widget.process('add_phone_number')
      expect(result[:json][:message]).to match /Phone number added/
    end

    it "should not add invalid Phone number" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      phone_info = {
        phone_number: '98765432',
        contact_purpose: 'default'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :add_phone_number, uuid, phone_info, nil)
      result = widget.process('add_phone_number')
      expect(result[:json][:message]).to match /Could not add phone number/
    end
  end

  describe "Remove phone number" do
    it "should remove phone number" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      @user.party.add_contact(PhoneNumber,{phone_number: '9876543210'},ContactPurpose.find_by_internal_identifier('default'))
      phone_info = {
        phone_number_id: PhoneNumber.last.id.to_s,
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :remove_phone_number, uuid, phone_info, nil)
      result = widget.process('remove_phone_number')
      expect(result[:json][:message]).to match /Phone number removed/
    end
  end

  describe "Add Address" do
    it "should add address" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      address_info = {
        address_line_1: 'Test',
        address_line_2: 'Test',
        city: 'City',
        state: '1',
        postal_code: '44074',
        contact_purpose: 'default'
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :add_address, uuid, address_info, nil)
      result = widget.process('add_address')
      expect(result[:json][:message]).to match /Address added/
    end
  end

  describe "Remove Address" do
    it "should remove address" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      login_user(@user)
      address = @user.party.add_contact(PostalAddress,{
        address_line_1: 'Test',
        address_line_2: 'Test',
        city: 'city',
        geo_zone_id: '1',
        state: GeoZone.find(1).zone_name,
        zip: '44074',
      },
      ContactPurpose.find_by_internal_identifier('default'))
      address_info = {
        address_id: PostalAddress.last.id.to_s
      }
      widget = Widgets::ManageProfile::Base.new(controller, "manage_profile", :remove_address, uuid, address_info, nil)
      result = widget.process('remove_address')
      expect(result[:json][:message]).to match /address removed/
    end
  end

  after(:all) do
    User.destroy_all
    Individual.destroy_all
    RoleType.destroy_all
    Party.destroy_all
    RelationshipType.destroy_all
  end
end