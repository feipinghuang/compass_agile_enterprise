module Knitkit
  module ErpApp
    module Desktop
      class InquiriesController < Knitkit::ErpApp::Desktop::AppController

        def index
          limit = params[:limit] || 15
          offset = params[:start] || 0

          website = Website.find(params[:website_id])
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'created_at'
          dir = sort_hash[:direction] || 'DESC'

          total = website.website_inquiries.count

          inquiries = website.website_inquiries.limit(limit).offset(offset).order(ActiveRecord::Base.sanitize_order_params(sort, dir))

          render :json => {:success => true, :total => total, :inquiries => inquiries.collect { |inquiry|
                             inquiry.to_hash(:only => [:id, :first_name, :last_name, :message, :email, :created_at],
                                             :username => (inquiry.created_by.nil? ? '' : inquiry.created_by.username)) }
                           }
        end

        def destroy
          website_inquiry = WebsiteInquiry.find(params[:id])
          website_inquiry.destroy
          render :json => {:success => true}
        end

      end #InquiriesController
    end #Desktop
  end #ErpApp
end #Knitkit
