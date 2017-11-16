module Knitkit
  module ErpApp
    module Desktop
      class ArticlesController < Knitkit::ErpApp::Desktop::AppController
        @@datetime_format = "%m/%d/%Y %l:%M%P"

        def new
          ActiveRecord::Base.transaction do
            begin
              current_user.with_capability('create', 'Content') do
                result = {}
                website_section_id = params[:section_id]
                article = Article.new

                article.tag_list = params[:tags].split(',').collect { |t| t.strip } unless params[:tags].blank?
                article.title = params[:title]
                article.internal_identifier = params[:internal_identifier]
                article.display_title = params[:display_title] == 'yes'
                article.created_by = current_user

                if article.save
                  # set the currents users dba_org as the dba_org for this content
                  article.add_party_with_role(current_user.party.dba_organization, RoleType.iid('dba_org'))

                  result[:node] = if website_section_id.blank?
                    {:text => params[:title],
                     :id => article.id,
                     :objectType => 'Article',
                     :parentItemId => params[:section_id],
                     :siteId => nil,
                     :iconCls => 'x-column-header-wysiwyg',
                     :leaf => true
                     }
                  else
                    website_section = WebsiteSection.find(website_section_id)
                    article.website_sections << website_section
                    website_section_content = article.update_content_area_and_position_by_section(website_section,
                                                                                                  params['content_area'],
                                                                                                  params['position'])

                    build_article_hash(website_section_content,
                                       website_section.website,
                                       website_section.is_blog?)
                  end

                  result[:success] = true
                else
                  result[:success] = false
                end

                render :json => result
              end
            rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
              render :json => {:success => false, :message => ex.message}
            end
          end
        end

        def update
          begin
            current_user.with_capability('edit', 'Content') do
              result = {}
              website_section_id = params[:section_id]
              article = Article.find(params[:id])

              article.tag_list = params[:tags].split(',').collect { |t| t.strip } unless params[:tags].blank?
              article.title = params[:title]
              article.internal_identifier = params[:internal_identifier]
              article.display_title = params[:display_title] == 'yes'
              article.updated_by = current_user

              if article.save
                unless website_section_id.blank?
                  website_section = WebsiteSection.find(website_section_id)
                  article.update_content_area_and_position_by_section(website_section,
                                                                      params['content_area'],
                                                                      params['position'])
                end

                result[:success] = true
              else
                result[:success] = false
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete
          begin
            current_user.with_capability('delete', 'Content') do
              render :json => Article.destroy(params[:id]) ? {:success => true} : {:success => false}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def add_existing
          begin
            current_user.with_capability('add_existing', 'Content') do
              website_section = WebsiteSection.find(params[:section_id])
              website_section.contents << Article.find(params[:article_id])
              website_section.save

              website_section_content = website_section.website_section_contents.where('content_id = ?', params[:article_id]).first

              render :json => {:success => true, :article => build_article_hash(website_section_content, website_section.website, website_section.is_blog?)}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def existing_articles
          render :inline => Article.with_party_role(current_user.party.dba_organization,
                                                    RoleType.iid('dba_org')).all.to_json(:only => [:internal_identifier, :id])
        end

        def show
          article = Article.find(params[:section_id])
          render :json => article.to_json
        end

        def get
          website_section_id = params[:section_id]
          section = WebsiteSection.find(website_section_id)

          if section.type == 'Blog'
            sort_default = 'contents.created_at'
            dir_default = 'DESC'
          else
            sort_default = 'title'
            dir_default = 'ASC'
          end

          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || sort_default
          dir = sort_hash[:direction] || dir_default
          limit = params[:limit] || 10
          start = params[:start] || 0

          articles = Article.joins("INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id")
          .where("website_section_id = #{Article.sanitize(website_section_id)}")
          total_count = articles.count
          articles = articles.order(ActiveRecord::Base.sanitize_order_params(sort, dir)).limit(limit).offset(start)

          Article.class_exec(website_section_id) do
            @@website_section_id = website_section_id

            def website_section_position
              self.website_section_contents.find_by_website_section_id(@@website_section_id).position
            end
          end

          articles_array = []
          articles.each do |a|
            articles_hash = {}
            articles_hash[:content_area] = a.content_area_by_website_section(WebsiteSection.find(website_section_id))
            articles_hash[:id] = a.id
            articles_hash[:title] = a.title
            articles_hash[:tag_list] = a.tag_list.join(', ')
            articles_hash[:internal_identifier] = a.internal_identifier
            articles_hash[:display_title] = a.display_title
            articles_hash[:position] = a.position(website_section_id)
            articles_hash[:created_at] = a.created_at.getlocal.strftime(@@datetime_format)
            articles_hash[:updated_at] = a.updated_at.getlocal.strftime(@@datetime_format)
            articles_array << articles_hash
          end

          render :inline => "{total:#{total_count},data:#{articles_array.to_json}}"
        end

        def all
          Article.include_root_in_json = false
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'title'
          dir = sort_hash[:direction] || 'ASC'
          limit = params[:limit] || 20
          start = params[:start] || 0

          articles = Article.with_party_role(current_user.party.dba_organization,
                                             RoleType.iid('dba_org')).includes(:website_section_contents)

          articles = articles.where(:website_section_contents => {:content_id => nil}) if params[:show_orphaned] == 'true'
          articles = articles.where("UPPER(contents.internal_identifier) LIKE UPPER('%#{Article.sanitize(params[:iid])}%')") unless params[:iid].blank?
          articles = articles.where("UPPER(contents.title) LIKE UPPER('%#{Article.sanitize(params[:title])}%')") unless params[:title].blank?
          articles = articles.where("UPPER(contents.body_html) LIKE UPPER('%#{Article.sanitize(params[:content])}%')
                                  OR UPPER(contents.excerpt_html) LIKE UPPER('%#{Article.sanitize(params[:content])}%')") unless params[:content].blank?
          articles = articles.order(ActiveRecord::Base.sanitize_order_params(sort, dir))
          total_count = articles.count
          articles = articles.limit(limit).offset(start)

          articles_array = []
          articles.each do |a|
            articles_hash = {}
            articles_hash[:id] = a.id
            articles_hash[:sections] = a.website_sections.collect { |section| section.title }.join(',')
            articles_hash[:title] = a.title
            articles_hash[:tag_list] = a.tag_list.join(', ')
            articles_hash[:body_html] = a.body_html
            articles_hash[:internal_identifier] = a.internal_identifier
            articles_hash[:display_title] = a.display_title
            articles_hash[:excerpt_html] = a.excerpt_html
            articles_hash[:created_by] = a.created_by.login rescue ''
            articles_hash[:last_update_by] = a.updated_by.login rescue ''
            articles_hash[:created_at] = a.created_at.getlocal.strftime(@@datetime_format)
            articles_hash[:updated_at] = a.updated_at.getlocal.strftime(@@datetime_format)


            articles_array << articles_hash
          end

          render :json => {total: total_count, data: articles_array}
        end

        def article_attributes
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'created_at'
          dir = sort_hash[:direction] || 'DESC'
          limit = params[:limit] || 40
          start = params[:start] || 0

          article = Article.find(params[:article_id])
          attributes = article.attribute_values
          attributes = attributes.slice(start.to_i, limit.to_i)

          if dir == "DESC"
            if sort == "data_type" or sort == "description"
              attributes = attributes.sort { |x, y| x.attribute_type.send(sort) <=> y.attribute_type.send(sort) }
            else
              attributes = attributes.sort { |x, y| x.send(sort) <=> y.send(sort) }
            end
          else
            if sort == "data_type" or sort == "description"
              attributes = attributes.sort { |x, y| y.attribute_type.send(sort) <=> x.attribute_type.send(sort) }
            else
              attributes = attributes.sort { |x, y| y.send(sort) <=> x.send(sort) }
            end
          end

          attributes_array = []
          attributes.each do |attribute|
            attributes_hash = {}
            attributes_hash[:id] = attribute.id
            attributes_hash[:description] = attribute.attribute_type.description
            attributes_hash[:data_type] = attribute.attribute_type.data_type
            attributes_hash[:value] = attribute.value

            attributes_array << attributes_hash
          end

          render :inline => "{data:#{attributes_array.to_json(:only => [:id, :description, :data_type, :value])}}"
        end

        def attribute_types
          attribute_types = AttributeType.find(:all)
          attribute_types_array = []
          attribute_types_array << {:description => 'Search By Article', :iid => 'search_by_article'}
          attribute_types.each do |attribute_type|
            attribute_types_hash = {}
            attribute_types_hash[:description] = attribute_type.description
            attribute_types_hash[:iid] = attribute_type.internal_identifier

            attribute_types_array << attribute_types_hash
          end

          render :inline => "{data:#{attribute_types_array.to_json(:only => [:description, :iid])}}"
        end

        def delete_attribute
          render :json => AttributeValue.destroy(params[:id]) ? {:success => true} : {:success => false}
        end

        def new_attribute
          result = {:success => true}
          article = Article.find(params[:article_id])
          attribute_type = AttributeType.find_by_iid_with_description(params[:description])

          if attribute_type == nil
            attribute_type = AttributeType.new
            attribute_type.description = params[:description]
            attribute_type.data_type = params[:data_type]
            result[:success] = false unless attribute_type.save

            attribute_value = AttributeValue.new
            attribute_value.value = params[:value]

            attribute_type.attribute_values << attribute_value
            article.attribute_values << attribute_value

            result[:success] = false unless attribute_value.save
          else
            if attribute_type.data_type == params[:data_type]
              attribute_value = AttributeValue.new
              attribute_value.value = params[:value]

              attribute_type.attribute_values << attribute_value
              article.attribute_values << attribute_value

              result[:sucess] = false unless attribute_value.save
            else
              result[:success] = false
            end
          end

          render :json => result
        end

      end #ArticlesController
    end #Desktop
  end #ErpApp
end #Knitkit
