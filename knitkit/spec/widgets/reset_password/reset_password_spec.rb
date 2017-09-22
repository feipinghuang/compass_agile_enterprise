require "spec_helper"

describe Widgets::ResetPassword::Base, type: :controller do

  #create dummy controller
  controller(ApplicationController) do end

  before(:all) do
    @website = FactoryGirl.create(:website, :configure_with_host, name: 'Test Website', host: 'localhost:3000')
    @test_user = FactoryGirl.create(:user)
  end

  describe "Get index" do
    context "without reset password token" do
      it "returns index" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(@website)

        widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :index, uuid, {}, nil)

        result = widget.process('index')
        expect(result).not_to be_empty
        expect(result).to render_template(:index)
      end
    end

    context "with reset password token" do
      it "returns reset password form" do
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
        expect(result).to render_template(:reset_password)
      end
    end

    context "with invalid reset password token" do
      it "returns invalid reset token template" do
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
        expect(result).to render_template(:invalid_reset_token)
      end
    end
  end

  describe "POST #update_password" do
    context "with valid token and password" do
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
        expect(result[:json][:html]).to render_template(:reset_success)
      end
    end

    context "with invalid token" do
      it "should not update user password" do
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
        expect(result[:json][:html]).to render_template(:invalid_reset_token)
      end
    end

    context "with invalid password and password combination" do
      it "should not update user" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(@website)

        @test_user.reset_password_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
        @test_user.reset_password_email_sent_at = Time.now.in_time_zone
        @test_user.reset_password_token_expires_at = Time.now.in_time_zone + 1.day
        @test_user.save

        update_password_params = {
          token: @test_user.reset_password_token,
          password: 'password1',
          password_confirmation: 'password'
        }

        widget = Widgets::ResetPassword::Base.new(controller, "reset_password", :update_password, uuid, update_password_params, nil)

        result = widget.process('update_password')
        expect(result[:json][:html]).to render_template(:reset_password)
      end
    end
  end

  after(:all) do
    @website.destroy if @website
    @test_user.destroy if @test_user
  end
end