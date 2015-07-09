module Knitkit
  module ErpApp
    module Desktop
      class WebsiteHostController < Knitkit::ErpApp::Desktop::AppController

        before_filter :set_website, :only => [:index]

        def index
          tree = []

          if @website
            @website.hosts.each do |website_host|

              tree << {:text => website_host.attributes['host'], :websiteHostId => website_host.id,
                       :host => website_host.attributes['host'], :iconCls => 'icon-globe',
                       :url => "http://#{website_host.attributes['host']}", :leaf => true}


            end
          end

          render :json => tree
        end

        def create
          begin
            current_user.with_capability('create', 'WebsiteHost') do
              website = Website.find(params[:website_id])
              existing_website_host = WebsiteHost.find_by_host(params[:host])
              if existing_website_host
                website_name = existing_website_host.website.name
                raise "Host #{existing_website_host.host} already used by #{website_name}"
              end
              website_host = WebsiteHost.create(:host => params[:host])
              website.hosts << website_host
              website.save

              render :json => {
                  :success => true,
                  :node => {
                      :text => website_host.attributes['host'],
                      :websiteHostId => website_host.id,
                      :host => website_host.attributes['host'],
                      :iconCls => 'icon-globe',
                      :url => "http://#{website_host.attributes['host']}",
                      :leaf => true}
              }
            end
          rescue => ex
            Rails.logger.error("#{ex.message} + #{ex.backtrace}")
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update
          begin
            current_user.with_capability('edit', 'WebsiteHost') do
              website_host = WebsiteHost.find(params[:id])
              existing_website_host = WebsiteHost.find_by_host(params[:host])
              if existing_website_host
                website_name = existing_website_host.website.name
                raise "Host #{existing_website_host.host} already used by #{website_name}"
              end
              website_host.host = params[:host]
              website_host.save

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          rescue => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def destroy
          begin
            current_user.with_capability('delete', 'WebsiteHost') do
              render :json => WebsiteHost.destroy(params[:id]) ? {:success => true} : {:success => false}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

      end # WebsiteHostController
    end # Desktop
  end # ErpApp
end # Knitkit
