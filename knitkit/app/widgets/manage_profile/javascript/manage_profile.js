Compass.ErpApp.Widgets.ManageProfile = {
    buildTemplate: function(websiteBuilder){
        if(websiteBuilder) {
            return new Ext.Template("<%= render_builder_widget :manage_profile %>");
        } else {
            return new Ext.Template("<%= render_widget :manage_profile %>");
        }
    },

    addWidget:function(options){
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        if(success) {
            var statement = Compass.ErpApp.Widgets.ManageProfile.buildTemplate(websiteBuilder).apply();
            success(statement);
        }
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Manage Profile',
    iconUrl:'/assets/icons/manage_profile/manage_profile_48x48.png',
    addWidget:Compass.ErpApp.Widgets.ManageProfile.addWidget,
    about:'This widget allows users to manage their user information, password and contact information.'
});
