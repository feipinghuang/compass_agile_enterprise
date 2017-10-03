require "spec_helper"

describe Widgets::GoogleMap::Base, type: :controller do

  #create dummy controller
  controller(ApplicationController) do end

  let(:user) { FactoryGirl.create(:user) }

  describe "GET #index" do
    it "returns index" do
      uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
      params =  { :drop_pins => [{:title => "TrueNorth.", :address => "1 S Orange Ave Orlando, FL 32801"}] }
      widget = Widgets::GoogleMap::Base.new(controller, "google_map", :index, uuid, params, nil)
      result = widget.process('index')

      expect(result).not_to be_empty
      expect(result).to render_template(:index)
    end
  end
end
