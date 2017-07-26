Compass.ErpApp.Widgets.Signup = {
    template: new Ext.Template('<%= render_widget :signup, :params => {:login_url => "/login"}%>'),
    addSignup: function () {
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(Compass.ErpApp.Widgets.Signup.template.apply());
    }
};

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name: 'Signup',
    iconUrl: '/assets/icons/sign_up/sign_up_48x48.png',
    onClick: Compass.ErpApp.Widgets.Signup.addSignup,
    about: 'This widget allows users to sign up.'
});