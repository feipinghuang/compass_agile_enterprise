module Knitkit
  module Extensions
    module Railties
      module ActionView
        module Helpers
          module MenuHelper

            def menu_active?(section, selected_section_parent)
              (!@website_section.nil? && section.id == @website_section.id) or 
              (!selected_section_parent.nil? and selected_section_parent.id == section.id)
            end

            def menu_item_selected(menu_item)
              result = request.env['REQUEST_PATH'] == menu_item.path
              unless result
                menu_item.descendants.each do |child|
                  result = request.env['REQUEST_PATH'] == child.path
                  break if result
                end
              end
              result
            end

            #options
            #menu
            # - use a designed layout not sections
            #layout
            # - use defined layout
            def render_menu(contents, options={})
              locals = {:contents => contents}

              if options[:locals]
                locals = locals.merge(options[:locals])
              end

              if options[:menu]
                menu = WebsiteNav.find_by_name_and_website_id(options[:menu], @website.id)
                raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
                layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_menu"
                locals[:menu_items] = menu.website_nav_items.positioned
              else
                layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_section_menu"
              end

              render :partial => layout, :locals => locals
            end

            #options
            #menu
            # - use a designed layout not sections
            #menu_item
            # - menu item title to start at
            #section_unique_name
            # - section to begin at
            #layout
            # - use defined layout
            def render_sub_menu(contents, options={})
              locals = {:contents => contents}
              if options[:menu]
                menu = WebsiteNav.find_by_name_and_website_id(options[:menu], @website.id)
                raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
                locals[:menu_items] = (options[:menu_item].nil? ? menu.all_menu_items.find { |item| menu_item_selected(item) }.positioned_children : menu.all_menu_items.find { |item| item.title = options[:menu_item] }.positioned_children)
                raise "No menu items exist" if locals[:menu_items].nil?
                layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_sub_menu"
              else
                section = options[:section_unique_name].nil? ? @website_section : WebsiteSection.find_by_internal_identifier(options[:section_unique_name])
                locals[:section] = section
                layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_sub_section_menu"
              end

              render :partial => layout, :locals => locals
            end

          end #MenuHelper
        end #Helpers
      end #ActionView
    end #Railties
  end #Extensions
end #Knitkit