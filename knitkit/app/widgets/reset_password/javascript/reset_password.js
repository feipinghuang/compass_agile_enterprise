Compass.ErpApp.Widgets.ResetPassword = {
    buildTemplate: function(websiteBuilder) {
        if(websiteBuilder) {
            return new Ext.Template("<%= render_builder_widget :reset_password, :params => {:login_url => '/login'}%>");
        } else {
            return new Ext.Template("<%= render_widget :reset_password, :params => {:login_url => '/login'}%>");
        }
    },
    
    addWidget:function(options){
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        if(options.success) {
            var statement = Compass.ErpApp.Widgets.ResetPassword.buildTemplate(websiteBuilder).apply();
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


