module Knitkit
  module ErpApp
    module Desktop
      class WebsiteNavItemController < Knitkit::ErpApp::Desktop::AppController

        def create
          begin
            current_user.with_capability('create', 'WebsiteNavItem') do
              result = {}
              klass = params[:klass].constantize
              parent = klass.find(params[:parent_id])
              website_nav = parent.is_a?(WebsiteNav) ? parent : parent.website_nav
              website_nav_item = WebsiteNavItem.new(:title => params[:title])

              url = params[:url]
              if params[:link_to] != 'url'
                #user wants to see Section so this is needed
                params[:link_to] = 'WebsiteSection' if params[:link_to] == 'website_section'

                #get link to item can be Article or Section
                linked_to_id = params["#{params[:link_to].underscore}_id".to_sym]
                link_to_item = params[:link_to].constantize.find(linked_to_id)
                #setup link
                website_nav_item.url = '/' + link_to_item.permalink
                website_nav_item.linked_to_item = link_to_item
                url = "http://#{website_nav.website.hosts.first.host}/" + link_to_item.permalink
              else
                website_nav_item.url = url
              end

              if website_nav_item.save
                if parent.is_a?(WebsiteNav)
                  parent.website_nav_items << website_nav_item
                else
                  website_nav_item.move_to_child_of(parent)
                end

                result[:success] = true
                result[:node] = {:text => params[:title],
                                 :linkToType => params[:link_to].underscore,
                                 :linkedToId => linked_to_id,
                                 :websiteNavId => website_nav.id,
                                 :url => url,
                                 :isSecure => false,
                                 :roles => [],
                                 :canAddMenuItems => true,
                                 :websiteNavItemId => website_nav_item.id,
                                 :iconCls => 'icon-document',
                                 :isWebsiteNavItem => true,
                                 :leaf => false,
                                 :children => []}
              else
                result[:success] = false
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update
          begin
            current_user.with_capability('edit', 'WebsiteNavItem') do
              result = {}
              website_nav_item = WebsiteNavItem.find(params[:id])
              website_nav_item.title = params[:title]

              url = params[:url]
              linked_to_id = nil
              if (params[:link_to] != 'url')
                #user wants to see Section so this is needed
                params[:link_to] = 'WebsiteSection' if params[:link_to] == 'website_section'

                #get link to item can be Article or Section
                linked_to_id = params["#{params[:link_to].underscore}_id".to_sym]
                link_to_item = params[:link_to].constantize.find(linked_to_id)
                #setup link
                website_nav_item.url = '/' + link_to_item.permalink
                website_nav_item.linked_to_item = link_to_item
                url = "http://#{website_nav_item.website_nav.website.hosts.first.host}/" + link_to_item.permalink
              else
                website_nav_item.url = url
              end

              if website_nav_item.save
                result[:success] = true
                result[:title] = params[:title]
                result[:linkedToId] = linked_to_id
                result[:linkToType] = params[:link_to].underscore
                result[:url] = url
              else
                result[:success] = false
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def destroy
          begin
            current_user.with_capability('delete', 'WebsiteNavItem') do
              render :json => (WebsiteNavItem.destroy(params[:id]) ? {:success => true} : {:success => false})
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update_security
          if current_user.has_capability?('secure', 'WebsiteNavItem') or current_user.has_capability?('unsecure', 'WebsiteNavItem')
            website_nav_item = WebsiteNavItem.find(params[:id])

            roles = JSON.parse(params[:security])

            if roles.blank? || roles.empty?
              website_nav_item.remove_capability(:view)
            else
              capability = website_nav_item.add_capability(:view)
              capability.remove_all_roles
              roles.each do |r|
                role = SecurityRole.find_by_internal_identifier(r)
                role.add_capability(capability)
              end
            end

            render :json => {:success => true, :secured => website_nav_item.is_secured?, :roles => website_nav_item.roles.collect { |item| item.internal_identifier }}
          else
            render :json => {:success => false, :message => "User does not have capability."}
          end
        end

      end # WebsiteNavItemController
    end # Desktop
  end # ErpApp
end # Knitkit
