require "spec_helper"

describe Widgets::Login::Base, type: :controller do

  #create dummy controller
  controller(ApplicationController) do end

  let(:user) { FactoryGirl.create(:user) }

  describe "GET #index" do
    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      params =  { :logout_to => "/login",
                           :login_to => "/home",
                           :signup_url => '/sign-up',
                           :reset_password_url => '/reset-password' }
      widget = Widgets::Login::Base.new(controller, "login", :index, uuid, params, nil)
      result = widget.process('index')

      expect(result).not_to be_empty
      expect(result).to render_template(:index)
      expect(result).to match(/Username or Email address/)
    end
  end

  describe "GET #login_header" do
      context 'when user logged in' do
        it "returns login header with logout link" do
          login_user(user)
          uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
          params =  { :login_url => "/login",
                               :signup_url => '/sign-up' }
          widget = Widgets::Login::Base.new(controller, "login", 'login_header', uuid, params, nil)
          result = widget.process('login_header')

          expect(result).not_to be_empty
          expect(result).to render_template(:login_header)
          expect(result).to match(/Logout/)
        end
      end

      context 'when user not logged in' do
        it "returns login header with login link" do
          uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
          params =  { :login_url => "/login",
                               :signup_url => '/sign-up' }
          widget = Widgets::Login::Base.new(controller, "login", 'login_header', uuid, params, nil)
          result = widget.process('login_header')

          expect(result).not_to be_empty
          expect(result).to render_template(:login_header)
          expect(result).to match(/Login/)
        end
      end
    end
end
