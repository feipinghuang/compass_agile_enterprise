Compass.ErpApp.Widgets.ManageProfile = {
    buildStatement: function(websiteBuilder){
        return Compass.ErpApp.Shared.Helpers.WidgetStatementBuilder.buildTemplate({
            widgetName: 'manage_profile',
            websiteBuilder: websiteBuilder
        }).apply();
    },

    addWidget:function(options){
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        if(success) {
            var statement = Compass.ErpApp.Widgets.ManageProfile.buildStatement(websiteBuilder);
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
