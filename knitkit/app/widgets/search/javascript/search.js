Compass.ErpApp.Widgets.Search = {
    buildTemplate: function(websiteBuilder){
        if(websiteBuilder) {
            return new Ext.Template(
                "<% #Optional Parameters:\n",
                "   # content_type: Leave blank to search all section types, set to Blog to only search Blog articles\n",
                "   # section_to_search: If set will only search for content within the specified section.  Set using a sections internal_identifier. \n",
                "   # results_permalink: How do you want your results to display? via ajax? or on a new page?\n",
                "   #                    Leave blank if you want results to display via ajax on the same page as the search form\n",
                "   #                    Enter the permalink of results page if you want the search results to display on a new page\n",
                "   # per_page: Number of results per page \n",
                "   # class: CSS class for the form \n",
                "%>\n",
                "<%= render_builder_widget :search, \n",
                "                          :action => get_widget_action,\n",
                "                          :params => set_widget_params({\n",
                "                               :content_type => '',\n",
                "                               :section_to_search => '',\n",
                "                               :results_permalink => '',\n",
                "                               :per_page => 20,\n",
                "                               :class => ''}) %>\n"
            )
            
        } else {
            
            return new Ext.Template(
                "<% #Optional Parameters:\n",
                "   # content_type: Leave blank to search all section types, set to Blog to only search Blog articles\n",
                "   # section_to_search: If set will only search for content within the specified section.  Set using a sections internal_identifier. \n",
                "   # results_permalink: How do you want your results to display? via ajax? or on a new page?\n",
                "   #                    Leave blank if you want results to display via ajax on the same page as the search form\n",
                "   #                    Enter the permalink of results page if you want the search results to display on a new page\n",
                "   # per_page: Number of results per page \n",
                "   # class: CSS class for the form \n",
                "%>\n",
                "<%= render_widget :search, \n",
                "                  :action => get_widget_action,\n",
                "                  :params => set_widget_params({\n",
                "                               :content_type => '',\n",
                "                               :section_to_search => '',\n",
                "                               :results_permalink => '',\n",
                "                               :per_page => 20,\n",
                "                               :class => ''}) %>\n"
            )
        }
    },

    addWidget:function(options){
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        var content = Compass.ErpApp.Widgets.Search.buildTemplate(websiteBuilder).apply();

        if(success) {
            success(content);
        }
    }
};

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Search',
    iconUrl:'/assets/icons/search/search_48x48.png',
    addWidget:Compass.ErpApp.Widgets.Search.addWidget,
    about:'This widget allows users to search for content in a website.'
});
