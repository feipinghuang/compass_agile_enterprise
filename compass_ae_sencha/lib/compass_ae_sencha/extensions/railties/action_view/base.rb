ActionView::Base.class_eval do
    
    def static_javascript_include_tag(*srcs)
      raw srcs.flatten.map { |src| "<script type=\"text/javascript\" src=\"/javascripts/#{src.include?('.js') ? src : "#{src}.js"}\"></script>" }.join("")
    end

    def static_stylesheet_link_tag(*srcs)
      raw srcs.flatten.map { |src| "<link rel=\"stylesheet\" type=\"text/css\" href=\"/stylesheets/#{src.include?('.css') ? src : "#{src}.css"}\" />" }.join("")
    end

    def include_extjs(opt={})
      resources = ''

      if opt[:debug]
        resources << javascript_include_tag("extjs/app-debug.js")
      else
        resources << javascript_include_tag("extjs/app.js")
      end

      resources << stylesheet_link_tag("extjs/resources/css/compass-ae-default-all.css") if opt[:theme] != false

      resources << add_authenticity_token_to_extjs

      # this requirement is new in ExtJS 4.1
      resources << "<script type=\"text/javascript\">Ext.Loader.setConfig({ enabled: true, disableCaching: false });</script>"

      raw resources
    end

    def include_sencha_touch(opt={})
      resources = ''

      if opt[:debug]
        resources << javascript_include_tag("sencha_touch/app-debug.js")
      else
        resources << javascript_include_tag("sencha_touch/app.js")
      end

      if opt[:theme] === false
        #do nothing not theme loaded.
      elsif opt[:theme]
        resources << stylesheet_link_tag("sencha_touch/resources/css/#{opt[:theme]}")
      else
        resources << stylesheet_link_tag("sencha_touch/app.css")
      end

      raw resources
    end
    
    def add_authenticity_token_to_extjs
      raw "<script type='text/javascript'>Ext.ns('Compass.ErpApp'); Ext.Ajax.extraParams = { client_utc_offset: (0 - new Date().getTimezoneOffset()),authenticity_token: '#{form_authenticity_token}' }; Compass.ErpApp.AuthentictyToken = '#{form_authenticity_token}';</script>"
    end
    
    def create_authenticity_token_sencha_touch_field
      raw "<script type='text/javascript'>Compass.ErpApp.Mobile.AuthentictyTokenField = {xtype:'hiddenfield', name:'authenticity_token', value:'#{form_authenticity_token}'}; </script>"
    end
    
    # example usage:
    # <%= dynamic_extjs_grid({
    #   :title => 'Accounts',
    #   :renderTo => 'grid_target',
    #   :setupUrl => build_widget_url(:accounts_grid_setup),
    #   :dataUrl => build_widget_url(:accounts_grid_data),
    #   :width => 500,
    #   :height => 200,
    #   :page => true,
    #   :pageSize => 5,
    #   :displayMsg => 'Displaying {0} - {1} of {2}',
    #   :emptyMsg => 'Empty',
    #   :storeId => "my_unique_store_id"   #this is an optional field
    # }) %>
    def dynamic_extjs_grid(options={})
      options[:title] = '' if options[:title].blank?
      options[:closable] = false if options[:closable].blank?
      options[:collapsible] = false if options[:collapsible].blank?
      options[:height] = 300 if options[:height].blank?

      raw "<script type='text/javascript'>new OnDemandLoadByAjax().load([
            '/javascripts/erp_app/shared/dynamic_editable_grid.js',
            '/javascripts/erp_app/shared/dynamic_editable_grid_loader_panel.js'],
          function(){
            var task = Ext.create('Ext.util.DelayedTask', function () { Ext.create('Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel', #{options.to_json} );});
            task.delay(200);
          });</script>"

    end
  
end
