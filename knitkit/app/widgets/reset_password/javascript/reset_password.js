Compass.ErpApp.Widgets.ResetPassword = {
    template: new Ext.Template('<%= render_widget :reset_password, :params => {:login_url => "/login"}%>'),
    buildStatement: function(websiteBuilder) {
        return Compass.ErpApp.Shared.Helpers.WidgetStatementBuilder.buildTemplate({
            widgetName: 'reset_password',
            websiteBuilder: websiteBuilder,
            params: {
                key: 'login_url',
                value: '/login'
            }
        }).apply();
    },
    
    addWidget:function(websiteBuilder){
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        if(options.success) {
            var statement = this.buildStatement(websiteBuilder);
            success(statement);
        }
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Reset Password',
    iconUrl:'/assets/icons/reset_password/reset_password_48x48.png',
    addWidget:Compass.ErpApp.Widgets.ResetPassword.addWidget,
    about:"This widget creates a form to submit for a user's password to be reset."
});


