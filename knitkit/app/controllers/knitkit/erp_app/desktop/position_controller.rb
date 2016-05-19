module Knitkit
  module ErpApp
    module Desktop
      class PositionController < Knitkit::ErpApp::Desktop::AppController

        around_filter :wrap_in_transaction

        def update_section_position
          params[:position_array].each do |position|
            website_section = WebsiteSection.find(position['id'])

            if position['parent_id'].blank? || position['parent_id'] == 'root'
              website_section.move_to_root
            else
              website_section.move_to_child_of(WebsiteSection.find(position['parent_id']))
            end

            website_section.position = position['position'].to_i

            website_section.save
          end

          render :json => {:success => true}
        end

        def update_menu_item_position
          params[:position_array].each do |position|
            website_nav_item = WebsiteNavItem.find(position['id'])
            website_nav_item.position = position['position'].to_i
            website_nav_item.save
          end

          render :json => {:success => true}
        end

        def update_article_position
          website_section = WebsiteSection.find(params[:section_id])

          params[:position_array].each do |position|
            article = website_section.website_section_contents.where('content_id = ?', position['id']).first
            article.position = position['position'].to_i
            article.save
          end

          render :json => {:success => true}
        end

        private

        def wrap_in_transaction
          begin
            ActiveRecord::Base.transaction do
              current_user.with_capability('drag_item', 'WebsiteTree') do
                yield
              end
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}

          rescue => ex
            Rails.logger.error ex.message + "\n"
            Rails.logger.error ex.backtrace.join("\n")

            # email notification
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render :json => {success: false, message: 'Could not process request'}
          end
        end

      end # PositionController
    end # Desktop
  end # ErpApp
end # Knitkit
