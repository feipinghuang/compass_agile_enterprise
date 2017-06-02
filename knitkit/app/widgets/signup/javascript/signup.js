Compass.ErpApp.Widgets.Signup = {
    buildTemplate: function(websiteBuilder) {
        if(websiteBuilder) {
            return new Ext.Template("<%= render_builder_widget :signup, :params => {:login_url => '/login'}%>");
        } else {
            return new Ext.Template("<%= render_widget :signup, :params => {:login_url => '/login'}%>");
        }
    },
    addWidget: function (options) {
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        var content = Compass.ErpApp.Widgets.Signup.buildTemplate(websiteBuilder).apply();

        if(success) {
            success(content);
        }
    }
};

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name: 'Signup',
    iconUrl: '/assets/icons/sign_up/sign_up_48x48.png',
    addWidget: Compass.ErpApp.Widgets.Signup.addWidget,
    about: 'This widget allows users to sign up.'
});
