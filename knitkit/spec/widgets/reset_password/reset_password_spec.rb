require "spec_helper"

describe Widgets::ResetPassword::Base, type: :controller do

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
    @test_user = FactoryGirl.create(:user)
  end

  describe "Get index" do
    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :index, uuid, {}, nil)

      result = widget.process('index')
      expect(result).to match(/id="reset_password_form"/)
    end

    it "should verify reset password token" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @test_user.reset_password_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      @test_user.reset_password_email_sent_at = Time.now.in_time_zone
      @test_user.reset_password_token_expires_at = Time.now.in_time_zone + 1.day
      @test_user.save

      reset_password_params = {
        reset_password_url: '/reset-password',
        token: @test_user.reset_password_token
      }

      widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :index, uuid, reset_password_params, nil)

      result = widget.process('index')
      expect(result).to match(/class="form-update_password"/)
    end

    it "should not verify invalid token" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @test_user.reset_password_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      @test_user.reset_password_email_sent_at = Time.now.in_time_zone
      @test_user.reset_password_token_expires_at = Time.now.in_time_zone + 1.day
      @test_user.save

      reset_password_params = {
        reset_password_url: '/reset-password',
        token: SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      }

      widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :index, uuid, reset_password_params, nil)

      result = widget.process('index')
      expect(result).to match(/Your password reset request looks invalid/)
    end
  end

  describe "Update Password" do
    it "should update user password" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @test_user.reset_password_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      @test_user.reset_password_email_sent_at = Time.now.in_time_zone
      @test_user.reset_password_token_expires_at = Time.now.in_time_zone + 1.day
      @test_user.save

      update_password_params = {
        login_url: '/login',
        token: @test_user.reset_password_token,
        password: 'password',
        password_confirmation: 'password'
      }

      widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :update_password, uuid, update_password_params, nil)

      result = widget.process('update_password')
      expect(result[:json][:html]).to match(/Your password has successfully been reset/)
    end

    it "should not update user password with invalid token" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @test_user.reset_password_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      @test_user.reset_password_email_sent_at = Time.now.in_time_zone
      @test_user.reset_password_token_expires_at = Time.now.in_time_zone + 1.day
      @test_user.save

      update_password_params = {
        login_url: '/login',
        token: SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz'),
        password: 'password',
        password_confirmation: 'password'
      }

      widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :update_password, uuid, update_password_params, nil)

      result = widget.process('update_password')
      expect(result[:json][:html]).to match(/Could not reset Password/)
    end

    it "should not update user password when password and password_confirmation don't match" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(@website)

      @test_user.reset_password_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      @test_user.reset_password_email_sent_at = Time.now.in_time_zone
      @test_user.reset_password_token_expires_at = Time.now.in_time_zone + 1.day
      @test_user.save

      update_password_params = {
        token: SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz'),
        password: 'password1',
        password_confirmation: 'password'
      }

      widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :update_password, uuid, update_password_params, nil)

      result = widget.process('update_password')
      expect(result[:json][:html]).to match(/Could not reset Password/)
    end
  end

  after(:all) do
    @website.destroy if @website
    @test_user.destroy if @test_user
  end
end