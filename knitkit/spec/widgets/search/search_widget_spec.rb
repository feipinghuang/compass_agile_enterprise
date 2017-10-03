require "spec_helper"

describe Widgets::Search::Base, type: :controller do

  #create dummy controller
  controller(ApplicationController) do end

  let(:user) { FactoryGirl.create(:user) }
  let(:website) { FactoryGirl.create(:website, :configure_with_host, name: 'Test Website', host: 'localhost:3000') }

  describe "GET #index" do
    context 'with display result via ajax on the same page' do
      it "returns index which contains search form" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        params =  { }
        widget = Widgets::Search::Base.new(controller, "search", :index, uuid, params, nil)
        result = widget.process('index')

        expect(result).not_to be_empty
        expect(result).to render_template(:index)
        expect(result).to match('<label for="search_for">Search For</label>')
        expect(result).to match('data-remote="true"')
      end
    end

    context 'with the permalink of results page to display on a new page' do
      it "returns index which contains search form" do
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        params = { redirect_results: true, results_permalink: '/search-results' }
        widget = Widgets::Search::Base.new(controller, "search", :index, uuid, params, nil)
        result = widget.process('index')

        expect(result).not_to be_empty
        expect(result).to render_template(:index)
        expect(result).to match('action="/search-results"')
        expect(result).to match('class="inline-search-header"')
      end
    end
  end


  describe "POST #search" do
    context 'with AJAX request to display on the same page' do
      it "returns JSON result" do
        allow(Website).to receive(:find_by_host).and_return(website)
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        params =  { search_query: 'test', per_page: 10 }
        widget = Widgets::Search::Base.new(controller, "search", :search, uuid, params, nil)
        allow(request).to receive('xhr?').and_return(true)
        result = widget.process('search')

        expect(result).not_to be_empty

        expect(result).to render_template(:show)
        expect(result[:json][:html]).not_to be_empty
      end
    end

    context 'with HTML request to display on a new page' do
      it "returns show page" do
        allow(Website).to receive(:find_by_host).and_return(website)
        uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(10000).to_s)
        params =  { search_query: 'test', per_page: 10 }
        widget = Widgets::Search::Base.new(controller, "search", :search, uuid, params, nil)
        result = widget.process('search')

        expect(result).not_to be_empty
        expect(result).to render_template(:show)
      end
    end
  end
end
