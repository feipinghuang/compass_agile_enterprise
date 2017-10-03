require "spec_helper"

RSpec.describe Widgets::ContactUs::Base, type: :controller do

  controller(ApplicationController) do end

  let(:website) { FactoryGirl.create(:website, :configure_with_host, name: 'Test Website', host: 'localhost:3000') }
  let(:website_inquiry_valid_params) { { first_name: 'John', last_name: 'Doe', message: 'Test inquiry message', email: 'test@example.com' } }
  let(:website_inquiry_invalid_params) { { first_name: '', last_name: '', message: '', email: '' } }

  describe "GET #index" do
    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      allow(Website).to receive(:find_by_host).and_return(website)
      widget = Widgets::ContactUs::Base.new(controller, "contact_us", :index, uuid, {} , nil)
      result = widget.process('index')

      expect(result).not_to be_empty
      expect(result).to render_template(:index)
    end
  end

  describe "POST #new" do
    context "with valid data" do
      it "should create website inquiry" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)
        widget = Widgets::ContactUs::Base.new(controller, "contact_us", :index, uuid, website_inquiry_valid_params , nil)
        allow(widget).to receive(:captcha_valid?).and_return(true)

        expect { widget.process('new') }.to change { WebsiteInquiry.count }.by(1)
      end
    end

    context "with invalid data & valid captcha" do
      it "should not create website inquiry" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)

        widget = Widgets::ContactUs::Base.new(controller, "contact_us", :index, uuid, website_inquiry_invalid_params , nil)
        allow(widget).to receive(:captcha_valid?).and_return(true)
        result = widget.process('new')

        expect(result[:json]).not_to be_empty
        expect(result[:json][:html]).to match(/An Error Occurred/)
        expect(result[:json][:html]).to match(/Email is invalid/)
      end
    end

    context "with valid data & invalid captcha" do
      it "should not create website inquiry" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        allow(Website).to receive(:find_by_host).and_return(website)
        widget = Widgets::ContactUs::Base.new(controller, "contact_us", :index, uuid, website_inquiry_valid_params , nil)
        allow(widget).to receive(:captcha_valid?).and_return(false)
        result = widget.process('new')

        expect(result[:json]).not_to be_empty
        expect(result[:json][:html]).to match(/An Error Occurred/)
        expect(result[:json][:html]).to match(/Captcha Invalid/)
      end
    end
  end
end
